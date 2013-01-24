package com.ijumboapp;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.ListView;
import android.widget.ProgressBar;


public class PlacesActivity extends IJumboActivity implements LoadActivityInterface {

	protected JSONArray buildings;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_places);
		this.buildings = this.getBuildingsFromStorage();
		this.showBuildingsInListView();
		new ActivityLoadThread(this).run();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_places, menu);
		return true;
	}

	@Override
	public void loadData() throws JSONException {
		// load it locally and display then load it from the server in case anything has changed
		this.buildings = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/buildings");
		this.writeBuildingsToStorage(this.buildings);
		this.showBuildingsInListView();
	}
	
	// If search is enabled make this take an argument
	private void showBuildingsInListView() {
		if(this.buildings == null) {
			return;
		}
		try {
			Object[] places = new Object[this.buildings.length()];
			for(int i = 0; i < this.buildings.length(); i++) {
				places[i] = this.buildings.get(i);
			}
			final ListView listV = (ListView) findViewById(R.id.placesList);
			final PlacesAdapter adapter = new PlacesAdapter(this, R.layout.listview_item_row, this.buildings);
	        this.runOnUiThread(new Runnable() { 
				@Override
				public void run() {
					listV.setAdapter(adapter);				
				}
			});			
        } catch (JSONException e) {
        	MainActivity.addErrorToDatabase("PlacesActivity", "showBuildingsInListView", e.toString());
			e.printStackTrace();
		}
	}
	
	// gets the data from internal stoarge and returns it 
	private JSONArray getBuildingsFromStorage() {
		FileInputStream fis = null;
		try {
			// keep it consistent with the json file
			fis = openFileInput("buildings");
		} catch (FileNotFoundException e) {
			MainActivity.addErrorToDatabase("PlacesActivity", "getBuildingsFromStorage1", e.toString());
			return null;
		}
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] b = new byte[1024];
		int bytesRead = 0;
		try {
			while ((bytesRead = fis.read(b)) != -1) {
			   bos.write(b, 0, bytesRead);
			}
		} catch (IOException e) {
			MainActivity.addErrorToDatabase("PlacesActivity", "getBuildingsFromStorage2", e.toString());
			e.printStackTrace();
		}
		byte[] bytes = bos.toByteArray();
		JSONArray fileBuildings = null;
		try {
			fileBuildings = new JSONArray(new String(bytes));
		} catch (JSONException e) {
			fileBuildings = null;
			MainActivity.addErrorToDatabase("PlacesActivity", "getBuildingsFromStorage3", e.toString());
			e.printStackTrace();
		}
		
		return fileBuildings;
	}
	
	private void writeBuildingsToStorage(JSONArray buildingsList) {
		if(buildingsList == null) {
			return;
		}
		FileOutputStream fos = null;
		try {
			fos = openFileOutput("buildings", Context.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			MainActivity.addErrorToDatabase("PlacesActivity", "writeBuildingsToStorage1", e.toString());
		}
		try {
			fos.write(buildingsList.toString().getBytes());
		} catch (IOException e) {
			MainActivity.addErrorToDatabase("PlacesActivity", "writeBuildingsToStorage2", e.toString());
		}
	}
	
	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.placesPD);
				pb.setVisibility(View.INVISIBLE);
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.placesPD);
				pb.setVisibility(View.VISIBLE);
			}
		});
	}
}

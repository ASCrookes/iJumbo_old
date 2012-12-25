package com.ijumboapp;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.widget.ListView;


public class PlacesActivity extends Activity implements LoadActivityInterface {

	protected JSONArray buildings;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_places);
		ListView lView = (ListView) findViewById(R.id.placesList);
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
		this.buildings = this.getBuildingsFromStorage();
		this.showBuildingsInListView();
		this.buildings = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/buildings");
		this.writeBuildingsToStorage(this.buildings);
		this.showBuildingsInListView();
	}
	
	// TODO -- if search is enabled make this take an argument
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
			System.out.println("DID NOT FIND FILE: " + e);
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
			e.printStackTrace();
		}
		byte[] bytes = bos.toByteArray();
		JSONArray fileBuildings = null;
		try {
			fileBuildings = new JSONArray(new String(bytes));
		} catch (JSONException e) {
			fileBuildings = null;
			e.printStackTrace();
		}
		System.out.println("THE BUILDING RECEIVED: " + fileBuildings);
		
		return fileBuildings;
	}
	
	private void writeBuildingsToStorage(JSONArray buildingsList) {
		FileOutputStream fos = null;
		try {
			fos = openFileOutput("buildings", this.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			System.out.println("WRITE BUILDINGS: " + e);
			e.printStackTrace();
		}
		try {
			fos.write(buildingsList.toString().getBytes());
		} catch (IOException e) {
			System.out.println("FOS WRITE: " + e);
			e.printStackTrace();
		}
	}
	
	@Override
	public void stopLoadingUI() {
		// TODO Auto-generated method stub		
	}

	@Override
	public void startLoadingUI() {
		// TODO Auto-generated method stub
	}
}

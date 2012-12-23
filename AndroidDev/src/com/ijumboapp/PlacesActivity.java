package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
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
		this.buildings = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/buildings");
		this.showBuildingsInListView();	
	}
	
	private void showBuildingsInListView() {
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
	
	@Override
	public void stopLoadingUI() {
		// TODO Auto-generated method stub		
	}

	@Override
	public void startLoadingUI() {
		// TODO Auto-generated method stub
	}
}

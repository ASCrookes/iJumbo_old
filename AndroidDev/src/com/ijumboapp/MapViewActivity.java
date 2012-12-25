package com.ijumboapp;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;


public class MapViewActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_map_view);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_map_view, menu);
		return true;
	}
	
	public void loadData() {
		// do shit here!!!!!!!!!!
	}

}

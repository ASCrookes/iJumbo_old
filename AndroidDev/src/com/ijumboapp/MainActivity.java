package com.ijumboapp;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		System.out.println("CREATED THE MAIN VIEW");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}

	public void getNews(View view) {
		Intent intent = new Intent(this, NewsActivity.class);
		startActivity(intent);
	}
	
	public void getMap(View view) {
		Intent intent = new Intent(this, PlacesActivity.class);
		startActivity(intent);
	}
	
	public void getEvents(View view) {
		Intent intent = new Intent(this, EventsActivity.class);
		startActivity(intent);
	}
	
	public void getJoey(View view) {
		Intent intent = new Intent(this, JoeyTableActivity.class);
		startActivity(intent);
	}
	
	public void getMenu(View view) {
		Intent intent = new Intent(this, MenuActivity.class);
		startActivity(intent);
	}
	
	public void getTrunk(View view) {
		Intent intent = new Intent(this, WebActivity.class);
		intent.putExtra("url", "https://trunk.tufts.edu/xsl-portal");
		startActivity(intent);
	}
	
}

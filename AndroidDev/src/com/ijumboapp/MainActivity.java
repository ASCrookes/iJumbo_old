package com.ijumboapp;

import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;



public class MainActivity extends Activity {
	
	final int NEWS_ACTIVITY_RESULT = 0;
	final int MENU_ACTIVITY_RESULT = 1;
	private HashMap<String, List<Article> > newsStories;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		this.setupIcons();
		this.newsStories = null;
		System.out.println("CREATED THE MAIN VIEW");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		how do i pass data back to the main activity to store data in RAM
		so that is does not have to load everytime
		
		Also, how do I write to the file system, to save things like the buildings list
		
		switch(requestCode) {
		case NEWS_ACTIVITY_RESULT:
			this.newsStories = (HashMap<String, List<Article> >) data.getSerializableExtra("newsStories");
			break;
		case MENU_ACTIVITY_RESULT:
			break;
		
		
		
		
		}
		
		
	}
	
	// puts the date on top of the calendar icon
	private void setupIcons() {
		
	}

	public void getNews(View view) {
		Intent intent = new Intent(this, NewsActivity.class);
		intent.putExtra("newsStories", this.newsStories);
		startActivityForResult(intent, NEWS_ACTIVITY_RESULT);
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

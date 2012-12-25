package com.ijumboapp;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;

import com.parse.Parse;
import com.parse.PushService;


public class MainActivity extends IJumboActivity {
	
	final static int   NEWS_ACTIVITY_RESULT = 0;
	final static int   MENU_ACTIVITY_RESULT = 1;
	final static int EVENTS_ACTIVITY_RESULT = 2;
	final int       GOOGLE_API_ERROR_DIALOG = 3;

	
	// data to simulate activity persistence
	private HashMap<String, List<Article> > newsStories;
	private long eventDate; // store the date used in milliseconds
	//this is the JSON string of the data source since JSONObjects cannot be passed with extras
	private byte[] menuDataSource;
	private long menuLastUpdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		Parse.initialize(this, "ctpSKiaBaM1DrFYqnknjV3ICFOfWcK5cD2GOB4Qc",
							   "YrPtqKjyvoWRoOMHFyPNLMhJgZbuXhzMu07JH1Qy");
		PushService.subscribe(this, "", MainActivity.class);
		PushService.setDefaultPushCallback(this, MainActivity.class);
		this.setupIcons();
		this.newsStories = null;
		this.menuDataSource = new byte[0];
		this.eventDate = -1;
		this.menuLastUpdate = -1;
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
		if(resultCode != Activity.RESULT_OK) {
			return;
		}
		switch(requestCode) {
		case NEWS_ACTIVITY_RESULT:
			this.newsStories = (HashMap<String, List<Article> >) data.getSerializableExtra("newsStories");
			break;
		case MENU_ACTIVITY_RESULT:
			this.menuDataSource = data.getByteArrayExtra("menuDataSource");
			this.menuLastUpdate = data.getLongExtra("menuLastUpdate", -1);
			break;
		case EVENTS_ACTIVITY_RESULT:
			this.eventDate = data.getLongExtra("eventDateString", -1);
			break;
		}
	}

	
	private void setupIcons() {
		// puts the current date on top of the calendar icon
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE", Locale.US);
		((TextView)findViewById(R.id.iconDay)).setText(dateFormat.format(date));
		dateFormat = new SimpleDateFormat("d", Locale.US);
		((TextView)findViewById(R.id.iconDayNumber)).setText(dateFormat.format(date));	
	}

	public void getNews(View view) {
		Intent intent = new Intent(this, NewsActivity.class);
		intent.putExtra("newsStories", this.newsStories);
		startActivityForResult(intent, NEWS_ACTIVITY_RESULT);
		this.newsStories = null;
	}
	
	
	public void getMap(View view) {
		Intent intent = new Intent(this, PlacesActivity.class);
		startActivity(intent);
	}
	
	public void getEvents(View view) {
		Intent intent = new Intent(this, EventsActivity.class);
		intent.putExtra("eventDateString", this.eventDate);
		startActivityForResult(intent, EVENTS_ACTIVITY_RESULT);
	}
	
	public void getJoey(View view) {
		Intent intent = new Intent(this, JoeyTableActivity.class);
		startActivity(intent);
	}
	
	public void getMenu(View view) {
		Intent intent = new Intent(this, MenuActivity.class);
		intent.putExtra("menuDataSource", this.menuDataSource);
		intent.putExtra("menuLastUpdate", this.menuLastUpdate);
		startActivityForResult(intent, MENU_ACTIVITY_RESULT);
	}
	
	public void getTrunk(View view) {
		Intent intent = new Intent(this, WebActivity.class);
		intent.putExtra("url", "https://trunk.tufts.edu/xsl-portal");
		intent.putExtra("title", "Trunk");
		startActivity(intent);
	}
}

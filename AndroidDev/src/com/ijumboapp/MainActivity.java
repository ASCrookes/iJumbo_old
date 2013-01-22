package com.ijumboapp;

import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;

import com.nullwire.trace.ExceptionHandler;
import com.parse.Parse;
import com.parse.ParseObject;
import com.parse.PushService;


public class MainActivity extends IJumboActivity {
	
	final static int   NEWS_ACTIVITY_RESULT = 0;
	final static int   MENU_ACTIVITY_RESULT = 1;
	final static int EVENTS_ACTIVITY_RESULT = 2;
	
	
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
		ExceptionHandler.register(this, "http://ijumboapp.com/api/error");
		this.setupIcons();
		this.newsStories = null;
		this.menuDataSource = new byte[0];
		this.eventDate = -1;
		this.menuLastUpdate = -1;
		System.out.println("CREATED THE MAIN VIEW");
		
		ConnectivityManager con = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		// TODO -- test that this actually knows when the phone is connected to the internet
		//         then move this to the request manager so it returns null from the background process
		//         and the wrapper functions will then deal with that
		if (con.getNetworkInfo(0).getState() == NetworkInfo.State.DISCONNECTED
                && con.getNetworkInfo(1).getState() == NetworkInfo.State.DISCONNECTED) {
			System.out.println("INTERNET NOT AVAILABLE");
			MainActivity.showAlert("Could not access the internet", this);
		} else {
			System.out.println("INTERNET WAS FOUND!");
		}
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}
	
	@SuppressWarnings("unchecked")
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
		default:
			break;
		}
	}

	
	private void setupIcons() {
		// puts the current date on top of the calendar icon
		/*
		Date date = new Date();
		SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE", Locale.US);
		((TextView)findViewById(R.id.iconDay)).setText(dateFormat.format(date));
		dateFormat = new SimpleDateFormat("d", Locale.US);
		((TextView)findViewById(R.id.iconDayNumber)).setText(dateFormat.format(date));	
		*/
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
		/*
		Intent intent = new Intent(this, WebActivity.class);
		intent.putExtra("url", "https://trunk.tufts.edu/xsl-portal");
		intent.putExtra("title", "Trunk");
		*/
		Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://trunk.tufts.edu/xsl-portal"));
		startActivity(intent);
	}
	
	static public void showAlert(String alert, Activity activity) {
		AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        builder.setMessage(alert);      
        builder.create().show();
	}
	
	static public void addErrorToDatabase(String theClass, String function, String errorMsg) {
		ParseObject error = new ParseObject("Error");
		error.put("class", theClass);
		error.put("function", function);
		error.put("errorMessage", errorMsg);
		error.saveEventually();
	}
}

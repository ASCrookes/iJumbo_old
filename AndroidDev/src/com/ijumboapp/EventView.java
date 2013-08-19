package com.ijumboapp;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.Menu;
import android.widget.TextView;


public class EventView extends IJumboActivity {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_event_view);
		TextView tView = (TextView) findViewById(R.id.eventDescription);
		if (tView == null)
			System.out.println("NULL SON");
		tView.setMovementMethod(new ScrollingMovementMethod());
		Intent intent = getIntent();
		JSONObject event;
		try {
			System.out.println(intent.getStringExtra("event"));
			event = new JSONObject(intent.getStringExtra("event"));
			if (event != null) {
				this.showEventInUI(event);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
				
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_event_view, menu);
		return true;
	}
	
	// take data in an Event object and display it
	public void showEventInUI(JSONObject event) throws JSONException {
		JSONObject innerEvent = event.getJSONObject("event");
		((TextView)findViewById(R.id.eventTitle)).setText(innerEvent.getString("title"));
		((TextView)findViewById(R.id.eventTime)).setText(event.getString("starts") + "-" + event.getString("ends"));
		((TextView)findViewById(R.id.eventLocation)).setText(innerEvent.getString("location"));
		((TextView)findViewById(R.id.eventLink)).setText("https://www.tuftslife.com/events/" + event.getInt("event_id"));
		((TextView)findViewById(R.id.eventDescription)).setText(innerEvent.getString("description"));
	}

}

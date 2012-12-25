package com.ijumboapp;

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
		tView.setMovementMethod(new ScrollingMovementMethod());
		Intent intent = getIntent();
		Event event = (Event) intent.getSerializableExtra("event");
		if(event != null) {
			this.showEventInUI(event);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_event_view, menu);
		return true;
	}
	
	// take data in an Event object and display it
	public void showEventInUI(Event event) {
		((TextView)findViewById(R.id.eventTitle)).setText(event.title);
		((TextView)findViewById(R.id.eventTime)).setText(event.startTime + "-" + event.endTime);
		((TextView)findViewById(R.id.eventLocation)).setText(event.location);
		((TextView)findViewById(R.id.eventLink)).setText(event.link);
		((TextView)findViewById(R.id.eventDescription)).setText(event.description);
	}

}

package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;

public class PlaceView extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_place_view);
		Intent intent = getIntent();
		JSONObject place = null;
		try {
			place = new JSONObject(intent.getStringExtra("place"));
			this.setupViewForLocation(place);
		} catch (JSONException e) {
			System.out.println("PLACE VIEW ON CREATE ERROR: " + e);
		}
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_place_view, menu);
		return true;
	}
	
	private void setupViewForLocation(JSONObject location) throws JSONException {
		if(location == null) {
			return;
		}
		((TextView)findViewById(R.id.placeAddress)).setText(location.getString("address"));
		((TextView)findViewById(R.id.placeWebsite)).setText(location.getString("website"));
		((TextView)findViewById(R.id.placePhone)).setText(location.getString("phone_number"));
		// the object can be an array or a bool(false)
		// check which one it is and then display/hide data accordingly
		Object hoursObj = location.get("hours");
		if(hoursObj.getClass().equals(JSONArray.class)) {
			JSONArray hours = (JSONArray) hoursObj;
			((TextView)findViewById(R.id.placeMonday)).setText(hours.getString(0) + "-" + hours.getString(1));
			((TextView)findViewById(R.id.placeTuesday)).setText(hours.getString(2) + "-" + hours.getString(3));
			((TextView)findViewById(R.id.placeWednesday)).setText(hours.getString(4) + "-" + hours.getString(5));
			((TextView)findViewById(R.id.placeThursday)).setText(hours.getString(6) + "-" + hours.getString(7));
			((TextView)findViewById(R.id.placeFriday)).setText(hours.getString(8) + "-" + hours.getString(9));
			((TextView)findViewById(R.id.placeSaturday)).setText(hours.getString(10) + "-" + hours.getString(11));
			((TextView)findViewById(R.id.placeSunday)).setText(hours.getString(12) + "-" + hours.getString(13));
		} else {
			this.hideHours();
		}
	}
	
	private void hideHours() {
		((TextView)findViewById(R.id.placeLabelHours)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelMonday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelTuesday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelWednesday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelThursday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelFriday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelSaturday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeLabelSunday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeMonday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeTuesday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeWednesday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeThursday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeFriday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeSaturday)).setVisibility(View.INVISIBLE);
		((TextView)findViewById(R.id.placeSunday)).setVisibility(View.INVISIBLE);
	}

}

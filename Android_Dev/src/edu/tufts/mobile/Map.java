package edu.tufts.mobile;

import android.app.Activity;
import android.os.Bundle;

public class Map extends /*Map*/Activity {

//	@Override
//	protected boolean isRouteDisplayed() {
//	    return false;
//	}
	
	@Override
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tm_map);
	}
	
}

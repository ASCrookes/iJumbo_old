package com.ijumboapp;

import org.json.JSONException;

import android.app.Activity;


public class ActivityLoadThread implements Runnable {
	
	private LoadActivityInterface activity;

	public ActivityLoadThread() {
		this.activity = null;
	}
	
	public ActivityLoadThread(LoadActivityInterface activity) {
		this.activity = activity;
	}
	
	// all activities load data using the load data function in the background
	// by passing the activity to this class. to avoid doing things when the 
	// internet is not available this does not call the load data function if 
	// the internet cannot be accessed because that can lead to unknown behavior
	@Override
	public void run() {
		if(this.activity != null && MainActivity.isNetworkAvailable((Activity) this.activity)) {
			System.out.println("going to load data");
			this.activity.startLoadingUI();
			try {
				this.activity.loadData();
			} catch (JSONException e) {}
			this.activity.stopLoadingUI();
		}
	}
}

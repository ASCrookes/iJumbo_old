package com.ijumboapp;

import org.json.JSONException;


public class ActivityLoadThread implements Runnable {
	
	private LoadActivityInterface activity;

	public ActivityLoadThread() {
		this.activity = null;
	}
	
	public ActivityLoadThread(LoadActivityInterface activity) {
		this.activity = activity;
	}
	
	@Override
	public void run() {
		if(this.activity != null) {
			this.activity.startLoadingUI();
			try {
				this.activity.loadData();
			} catch (JSONException e) {}
			this.activity.stopLoadingUI();
		}
	}
}

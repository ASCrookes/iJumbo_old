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
			try {
				this.activity.loadData();
			} catch (JSONException e) {
				System.out.println("ActivityLoadThread loadData Error: " + e);
				e.printStackTrace();
			}
		} else {
			System.out.println("ActivityLoadThread: There is no activity to run loadData on!");
		}
	}
}

package com.ijumboapp;

import org.json.JSONException;

import android.os.AsyncTask;


public class LoadDataBackground extends AsyncTask<LoadActivityInterface, Void, Void> {

	@Override
	protected Void doInBackground(LoadActivityInterface... params) {
		// show that data is loading in the UI
		// load the data
		// stop the loading UI
		LoadActivityInterface activity = params[0];
		activity.startLoadingUI();
		try {
			activity.loadData();
		} catch (JSONException e) {}
		activity.stopLoadingUI();
		return null;
	}
}

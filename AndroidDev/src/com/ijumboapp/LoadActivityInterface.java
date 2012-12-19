package com.ijumboapp;

import org.json.JSONException;

import android.app.ProgressDialog;

public interface LoadActivityInterface {
	public void loadData() throws JSONException;
	public void stopLoadingUI();
	public void startLoadingUI();
}

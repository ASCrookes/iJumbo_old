package com.ijumboapp;

import org.json.JSONException;


public interface LoadActivityInterface {
	public void loadData() throws JSONException, JSONException;
	public void stopLoadingUI();
	public void startLoadingUI();
}

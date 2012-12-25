package com.ijumboapp;

import android.app.ActionBar;
import android.app.Activity;
import android.os.Bundle;

// used to set the action bar's color
public class IJumboActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ActionBar bar = getActionBar();
		bar.setBackgroundDrawable(this.getResources().getDrawable(R.drawable.nav_bar));
	}
}

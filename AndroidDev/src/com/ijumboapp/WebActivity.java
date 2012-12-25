package com.ijumboapp;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.webkit.WebView;



public class WebActivity extends IJumboActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        Intent intent = getIntent();
        String url = intent.getStringExtra("url");     	
       	if(url != null) {
       		// set the webView as this activity's main view
       		WebView webView = new WebView(this);
       		webView.loadUrl(url);
       		this.setContentView(webView);
       	}
       	String title = intent.getStringExtra("title");
       	if(title != null) {
       		setTitle(title);
       	}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_web, menu);
		return true;
	}
}

package com.ijumboapp;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.webkit.WebView;

public class WebActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        WebView webView = new WebView(this);
        // set the webView as this activity's main view
        
        Intent intent = getIntent();
        String url = intent.getStringExtra("url");

        webView.getSettings().setBuiltInZoomControls(true);
       	webView.setInitialScale(1);
       	webView.getSettings().setAppCacheEnabled(false);
       	webView.getSettings().setJavaScriptEnabled(true);
       	webView.loadUrl(url);
       	
       	if(url != null)
       		setContentView(webView);
	}


	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_web, menu);
		return true;
	}

}

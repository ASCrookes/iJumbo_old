package edu.tufts.mobile;

import android.app.Activity;
import android.webkit.WebView;
import android.os.Bundle;

public class Trunk extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tm_trunk);
		
		WebView webview = new WebView(this);
		setContentView(webview);
		webview.loadUrl("https://trunk.tufts.edu/");
	}
	
}

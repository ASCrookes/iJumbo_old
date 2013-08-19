package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

public class LinksActivity extends IJumboActivity implements LoadActivityInterface {

	private JSONArray links;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_links); 
        ListView lView = (ListView) findViewById(R.id.linksList);
        lView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
									long arg3) {
				if (arg2 % 2 != 0)
					return;
				try {
					String url = LinksActivity.this.links.getJSONObject(arg2/2).getString("link");
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
					startActivity(intent);
				} catch (JSONException e) {} 
				
			}
		});
        if (this.links == null || this.links.length() == 0) {
        	new Thread(new ActivityLoadThread(this)).start();
        }
    }
	
	@Override
	public void loadData() throws JSONException, JSONException {
		this.links = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/links");
		final ListView listV = (ListView) findViewById(R.id.linksList);
		final LinksAdapter adapter = new LinksAdapter(this, 0, this.links);
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				listV.setAdapter(adapter);	
			}
		});
	}

	@Override
	public void stopLoadingUI() {

	}

	@Override
	public void startLoadingUI() {
		
	}

}

package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ListView;
import android.widget.ProgressBar;

public class JoeyTableActivity extends Activity implements LoadActivityInterface {

	private JSONArray dataSource;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_joey_table);
        System.out.println("IN ON CREATE FOR JOEY TABLE");
        new Thread(new ActivityLoadThread(this)).start();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_joey_table, menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
        switch (item.getItemId()) {
        case R.id.joeyRefreshMenuItem:
        	new Thread(new ActivityLoadThread(this)).start();
        	return true;   
        default:
        	return super.onOptionsItemSelected(item);
        }
    }
        
        
    // gets the data from the server
    // loads it into the table
    public void loadData() {
    	final ListView listV = (ListView) findViewById(R.id.joeyList);
        try {
			this.dataSource = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/joey");
			String[] etas = new String[this.dataSource.length()];
			for(int i = 0; i < this.dataSource.length(); i++) {
				JSONObject jsonObj = (JSONObject) this.dataSource.get(i);
				etas[i] = jsonObj.get("location") + ": " + jsonObj.get("ETA");
			}
	        final EventsAdapter adapter = new EventsAdapter(this, android.R.layout.simple_list_item_1, etas);
			this.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					listV.setAdapter(adapter);				
				}
			});			
        } catch (JSONException e) {
			e.printStackTrace();
		}
    }

	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.joeyPD);
				pb.setVisibility(View.INVISIBLE);
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.joeyPD);
				pb.setVisibility(View.VISIBLE);
			}
		});
	}
}

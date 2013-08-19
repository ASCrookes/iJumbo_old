package com.ijumboapp;

import java.util.Calendar;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.AdapterView.OnItemClickListener;


public class JoeyTableActivity extends IJumboActivity implements LoadActivityInterface {

	private JSONArray dataSource;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_joey_table);
        new Thread(new ActivityLoadThread(this)).start();
        
        ListView lView = (ListView) findViewById(R.id.joeyList);
        lView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
									long arg3) {
				if (arg2 == 0) {
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(JoeyTableActivity.this.getURLBasedOnTime()));
					startActivity(intent);
				}
			}
		});
    }
    
    public String getURLBasedOnTime() {
    	String url = "";
    	Calendar cal = Calendar.getInstance();  // TODO(amadou): set to new york time zone
		int day_of_week = cal.get(Calendar.DAY_OF_WEEK);
		if (day_of_week == Calendar.SUNDAY) {
			url = "http://publicsafety.tufts.edu/adminsvc/sunday-schedule-2/";
		} else if (day_of_week == Calendar.SATURDAY) {
			url = "http://publicsafety.tufts.edu/adminsvc/saturday-schedule-2/";
		} else {
			int hour = cal.get(Calendar.HOUR_OF_DAY);
			if (hour < 18) {
				url = "http://publicsafety.tufts.edu/adminsvc/day-schedule-monday-friday/";
			} else if (day_of_week < Calendar.THURSDAY) {
				url = "http://publicsafety.tufts.edu/adminsvc/night-schedule-monday-wednesday-2/";
			} else {
				url = "http://publicsafety.tufts.edu/adminsvc/night-schedule-thursday-friday-2/";
			}
		}
    	return url;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_joey_table, menu);
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int itemId = item.getItemId();
		if (itemId == R.id.joeyRefreshMenuItem) {
			new Thread(new ActivityLoadThread(this)).start();
			return true;
		} else {
			return super.onOptionsItemSelected(item);
		}
    }    
        
    // gets the data from the server
    // loads it into the table
    public void loadData() {
    	final ListView listV = (ListView) findViewById(R.id.joeyList);
        try {
			this.dataSource = new RequestManager().getJSONArray("http://ijumboapp.com/api/json/joey");
			if(this.dataSource == null) {
				return;
			}
			String[] etas = new String[this.dataSource.length()];
			for(int i = 0; i < this.dataSource.length(); i++) {
				JSONObject jsonObj = (JSONObject) this.dataSource.get(i);
				etas[i] = jsonObj.get("location") + ": " + jsonObj.get("ETA");
			}
	        final JoeyAdapter adapter = new JoeyAdapter(this, android.R.layout.simple_list_item_1, etas);
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

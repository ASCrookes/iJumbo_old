package com.ijumboapp;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.ProgressBar;


public class EventsActivity extends IJumboActivity implements LoadActivityInterface {
	final long MILLISECONDS_IN_DAY = 86400000;
	private Date date;
	private JSONObject eventsDict;
	// events is used to catch the data
	// data source is what the table uses
	//private List <Event> dataSource;
	private MenuItem dateItem;
	private int loadingThreads; // used to stop the loading ui once all threads are done
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_events); 
        ListView lView = (ListView) findViewById(R.id.eventsList);
        lView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
									long arg3) {
				String key = EventsActivity.this.getDatedKey();
				JSONArray events;
				try {
					events = EventsActivity.this.eventsDict.getJSONArray(key);
					JSONObject event = events.getJSONObject(arg2);
					Intent intent = new Intent(EventsActivity.this, EventView.class);
					intent.putExtra("event", event.toString());
					EventsActivity.this.startActivity(intent);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				
			}
		});
    }
    
    // data loading relies on the ui, some of that gets initially set here
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_events, menu);
        this.dateItem = menu.findItem(R.id.eventDate);
        long dateString = getIntent().getLongExtra("eventDateString", -1);
        if(dateString == -1) {
        	this.setDate(new Date());
        } else {
        	this.setDate(new Date(dateString));
        }
        
        // the below line calls this.loadData in a background thread
        this.loadingThreads = 0;
        new Thread(new ActivityLoadThread(this)).start();
        return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	int itemId = item.getItemId();
		if (itemId == R.id.eventsPrevious) {
			this.setDate(new Date(this.date.getTime() - MILLISECONDS_IN_DAY));
			return true;
		} else if (itemId == R.id.eventNext) {
			this.setDate(new Date(this.date.getTime() + MILLISECONDS_IN_DAY));
			return true;
		} else if (itemId == R.id.eventDate) {
			this.setDate(new Date());
			return true;
		} else {
			return super.onOptionsItemSelected(item);
		}
    }
    
    @Override
	public void onBackPressed() {
		Intent resultIntent = new Intent();
		resultIntent.putExtra("eventDateString", this.date.getTime());
		setResult(Activity.RESULT_OK, resultIntent);
		finish();
	}
        
    public void loadData() throws JSONException {
    	String url = "https://www.tuftslife.com/events.json";
    	this.eventsDict = new RequestManager().getJSONObject(url);
    	String dateKey = this.getDatedKey();
    	System.out.println(dateKey);
    	JSONArray eventsList;
    	if (this.eventsDict.has(dateKey))
    		eventsList = (JSONArray) this.eventsDict.get(dateKey);
    	else
    		eventsList = new JSONArray();
    		
    	final EventsAdapter adapter = new EventsAdapter(this, 0, eventsList);
        //final ArrayAdapter<Event> adapter =  new ArrayAdapter<Event>(this, android.R.layout.simple_list_item_1, android.R.id.text1, eventsList);
    	final ListView listV = (ListView) findViewById(R.id.eventsList);
    	this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if(EventsActivity.this.loadingThreads == 1) {
					listV.setAdapter(adapter);	
				}
			}
		});
    }
    
    public String getDatedKey() {
    	SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
    	return dateFormat.format(this.date);
    }
    
    // force the loading UI functions into the ui thread
    // the are called from a background thread
	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				EventsActivity.this.loadingThreads--;
				if(EventsActivity.this.loadingThreads == 0) {
					ProgressBar pb = (ProgressBar) findViewById(R.id.eventsPD);
					pb.setVisibility(View.INVISIBLE);
				}
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if(EventsActivity.this.loadingThreads == 0) {
					ProgressBar pb = (ProgressBar) findViewById(R.id.eventsPD);
					pb.setVisibility(View.VISIBLE);
				}
				EventsActivity.this.loadingThreads++;
			}
		});
	}
    
	public void setDate(Date newDate) {
		this.date = newDate;
		new Thread(new ActivityLoadThread(this)).start();
		SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd", Locale.US);
		this.dateItem.setTitle(dateFormat.format(this.date));
	}
}

package com.ijumboapp;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.Spinner;


public class MenuActivity extends IJumboActivity implements LoadActivityInterface {

	private JSONObject masterDict;
	private JSONArray dataSource;
	private long lastUpdate;
	private Spinner hallSpinner;
	private Spinner mealSpinner;
	private JSONObject diningHallInfo;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);
    }
    

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_menu, menu);
        this.hallSpinner = (Spinner) menu.findItem(R.id.diningHallSpinner).getActionView();
        this.mealSpinner = (Spinner) menu.findItem(R.id.mealSpinner).getActionView();
        // the item listener used by the spinners in the action bar
        AdapterView.OnItemSelectedListener spinnerItemListener = new AdapterView.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				try {
					if(MenuActivity.this.dataSource == null) {
						MenuActivity.this.loadData();
					} else {
						MenuActivity.this.displayDataBasedOnUI();
					}
				} catch (JSONException e) {}
			}
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
		};
		// both spinners should just call displayDataBasedOnUI after an item is selected
        this.hallSpinner.setOnItemSelectedListener(spinnerItemListener);
        this.mealSpinner.setOnItemSelectedListener(spinnerItemListener);
        
        // sometimes the data that loads relies on the menu spinners
        // so load after the spinners have been inflated from xml
        try {
        	Intent intent = getIntent();
        	this.masterDict = new JSONObject(new String(intent.getByteArrayExtra("menuDataSource")));
        	this.lastUpdate = intent.getLongExtra("menuLastUpdate", -1);
		} catch (JSONException e1) {}
        try {
			this.loadDataBasedOnDate();
		} catch (JSONException e) {
			e.printStackTrace();
		}
        this.diningHallInfo = this.getDiningHallInfoFromStorage();
        
        return true;
    }
    
	@Override
	public void onBackPressed() {
		Intent resultIntent = new Intent();
		resultIntent.putExtra("menuDataSource", this.masterDict.toString().getBytes());
		resultIntent.putExtra("menuLastUpdate", this.lastUpdate);
		setResult(Activity.RESULT_OK, resultIntent);
		finish();
	}
    
    private void loadDataBasedOnDate() throws JSONException {
    	long serversUpdate = new RequestManager().getJSONObject("http://ijumboapp.com/api/json/mealDate").getLong("date");
    	// if the server updated more recently than the device pulled load the data again
    	// or if this activity does not have the data load again
    	if(serversUpdate >= this.lastUpdate || this.masterDict == null || this.masterDict.length() == 0) {
    		new Thread(new ActivityLoadThread(this)).start();
    	} else {
    		this.displayDataBasedOnUI();
    	}
    }

    public void loadData() throws JSONException {
    	if(this.diningHallInfo == null) {
    		this.diningHallInfo = new RequestManager().getJSONObject("http://ijumboapp.com/api/json/diningHallInfo");
    	}
    	this.masterDict = new JSONObject(new RequestManager().get("http://ijumboapp.com/api/json/meals"));
    	this.displayDataBasedOnUI();
    	this.writeDiningHallInfoToStorage(new RequestManager().getJSONObject("http://ijumboapp.com/api/json/diningHallInfo"));
    }
    
    private void displayDataBasedOnUI() throws JSONException {
    	JSONObject diningHall  = (JSONObject) this.masterDict.get(this.getDiningHall());
    	JSONObject meal = (JSONObject) diningHall.get((this.getDiningHall().equals("Hodgdon")) ? "Breakfast" : this.getMeal());
    	this.dataSource  = (JSONArray) meal.get("sections");
    	this.displayDataSource();
    }
    
    private void displayDataSource() throws JSONException {
    	JSONObject[] dataList = new JSONObject[this.dataSource.length()];
    	// make a custom adapter that will grab this information from the data source as opposed to manually getting it
    	for(int i = 0; i < this.dataSource.length(); i++) {
    		dataList[i] = (JSONObject) this.dataSource.get(i);
    	}
    	final ListView listV = (ListView) findViewById(R.id.menuList);
    	//Make this work to create the correct adapter
    	final MenuAdapter adapter = new MenuAdapter(this, R.layout.listview_item_row, dataList, this.getDiningHall(), this.diningHallInfo);
        this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				listV.setAdapter(adapter);				
			}
		});        
        // set the new date to now instead of what the server says to avoid weird conflicts
        this.setLastUpdate(new Date());
    }

    private void setLastUpdate(Date date) {
    	SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyyMMddHHmm");
    	// the server puts the date in USA eastern time
    	dateFormatter.setTimeZone(TimeZone.getTimeZone("America/New_York"));
    	this.lastUpdate = Long.parseLong(dateFormatter.format(date));
    }
    
    private String getDiningHall() {
    	// this.spinner has the hall -> toString the selected hall
    	return this.hallSpinner.getSelectedItem().toString();
    }
    
    private String getMeal() {
    	// maybe make another spinner for the the meal so the spinners
    	// would read like "Dewick" + "Dinner"
    	return this.mealSpinner.getSelectedItem().toString();
    }

	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.menuPD);
				pb.setVisibility(View.INVISIBLE);
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pb = (ProgressBar) findViewById(R.id.menuPD);
				pb.setVisibility(View.VISIBLE);
			}
		});
	}
	
	// gets the data from internal stoarge and returns it 
		private JSONObject getDiningHallInfoFromStorage() {
			FileInputStream fis = null;
			try {
				// keep it consistent with the json file
				fis = openFileInput("diningHallInfo");
			} catch (FileNotFoundException e) {
				return null;
			}
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			byte[] b = new byte[1024];
			int bytesRead = 0;
			try {
				while ((bytesRead = fis.read(b)) != -1) {
				   bos.write(b, 0, bytesRead);
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			byte[] bytes = bos.toByteArray();
			JSONObject diningHallInfo = null;
			try {
				diningHallInfo = new JSONObject(new String(bytes));
			} catch (JSONException e) {
				diningHallInfo = null;
				e.printStackTrace();
			}
			
			return diningHallInfo;
		}
		
		private void writeDiningHallInfoToStorage(JSONObject diningHallInfo) {
			FileOutputStream fos = null;
			try {
				fos = openFileOutput("diningHallInfo", Context.MODE_PRIVATE);
			} catch (FileNotFoundException e) {}
			try {
				fos.write(diningHallInfo.toString().getBytes());
			} catch (IOException e) {}
		}
}

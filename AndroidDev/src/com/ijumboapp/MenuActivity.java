package com.ijumboapp;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Spinner;

public class MenuActivity extends Activity implements LoadActivityInterface {

	private JSONObject masterDict;
	private JSONArray dataSource;
	private long lastUpdate;
	private Spinner hallSpinner;
	private Spinner mealSpinner;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);
        this.lastUpdate = -1;
        this.dataSource = null;
        this.masterDict = null;	
        try {
			this.loadDataBasedOnDate();
		} catch (JSONException e) {
			e.printStackTrace();
		}
    }
    

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_menu, menu);
        this.hallSpinner = (Spinner) menu.findItem(R.id.diningHallSpinner).getActionView();
        this.mealSpinner = (Spinner) menu.findItem(R.id.mealSpinner).getActionView();
        // the item listener used by the spinners in the action bar
        AdapterView.OnItemSelectedListener spinnerItemListener = new AdapterView.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					                   int arg2, long arg3) {
				try {
					if(MenuActivity.this.dataSource == null) {
						MenuActivity.this.loadData();
					} else {
						MenuActivity.this.displayDataBasedOnUI();
					}
				} catch (JSONException e) {
					System.out.println("MENU ACTIVITY ERROR: " + e);
				}
			}
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
		};
		// both spinners should just call displayDataBasedOnUI after an item is selected
        this.hallSpinner.setOnItemSelectedListener(spinnerItemListener);
        this.mealSpinner.setOnItemSelectedListener(spinnerItemListener);
        
        return true;
    }
    
    private void loadDataBasedOnDate() throws JSONException {
    	long serversUpdate = new RequestManager().getJSONObject("http://ijumboapp.com/api/json/mealDate").getLong("date");
    	// if the server updated more recently than the device pulled load the data again
    	if(serversUpdate >= this.lastUpdate || !(this.dataSource == null) || this.dataSource.length() == 0) {
    		new Thread(new ActivityLoadThread(this)).start();
    	}
    }

    public void loadData() throws JSONException {
    	this.masterDict = new JSONObject(new RequestManager().get("http://ijumboapp.com/api/json/meals"/* change this url! */));
    	this.displayDataBasedOnUI();
    }
    
    private void displayDataBasedOnUI() throws JSONException {
    	JSONObject diningHall  = (JSONObject) this.masterDict.get(this.getDiningHall());
    	JSONObject meal = (JSONObject) diningHall.get( (this.getDiningHall().equals("Hodgdon")) ? "Breakfast" : this.getMeal());
    	this.dataSource  = (JSONArray) meal.get("sections");
    	JSONObject[] dataList = new JSONObject[this.dataSource.length()];
    	// make a custom adapter that will grab this information from the data source as opposed to manually getting it
    	for(int i = 0; i < this.dataSource.length(); i++) {
    		dataList[i] = (JSONObject) this.dataSource.get(i);
    	}
    	final ListView listV = (ListView) findViewById(R.id.menuList);
    	//Make this work to create the correct adapter
    	final MenuAdapter adapter = new MenuAdapter(this, R.layout.listview_item_row, dataList, this.getDiningHall());
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
    	SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyyMMddHmm");
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
		// TODO Auto-generated method stub
	}


	@Override
	public void startLoadingUI() {
		// TODO Auto-generated method stub
	}
}

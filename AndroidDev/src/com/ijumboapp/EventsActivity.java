package com.ijumboapp;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

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
	private String currentTag;
	private Event currentEvent;
	// events is used to catch the data
	private List <Event> events;
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
				Event event = EventsActivity.this.events.get(arg2);
				Intent intent = new Intent(EventsActivity.this, EventView.class);
				intent.putExtra("event", event);
				EventsActivity.this.startActivity(intent);
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
        
    public void loadData() {
    	String xml = new RequestManager().get(this.getURL());
    	// load it into a stream
    	if(xml == null) {
    		System.out.println("Events xml was null");
    		return;
    	}
    	InputStream inStream = new ByteArrayInputStream(xml.getBytes());
    	try {
    		// parse through it
			this.parseThatIsh(inStream);
		} catch (XmlPullParserException e) {} 
    	  catch (IOException e) {}
    }
    
    private String getURL() {
    	String url = "https://www.tuftslife.com/occurrences.rss?date=";
    	SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM+d%2'C'+y", Locale.US);
    	url = url + dateFormat.format(this.date);
    	//url = "https://www.tuftslife.com/occurrences.rss?date=November+26%2C+2012";
    	return url;
    }
    
    private void parseThatIsh(InputStream inStream) throws XmlPullParserException, IOException {
    	// keep track of the threads when this starts, if that changes--STOP
    	int currentThreads = this.loadingThreads;
    	XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        factory.setNamespaceAware(true);
        XmlPullParser xpp = factory.newPullParser();
        	
        xpp.setInput(inStream, null);
        int eventType = xpp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT && this.loadingThreads == currentThreads) {
        	if(eventType == XmlPullParser.START_DOCUMENT) {
        		this.events = new ArrayList<Event>();
        		this.currentEvent = new Event();
        	} else if(eventType == XmlPullParser.START_TAG) {
        		this.currentTag = xpp.getName();
        		if(this.currentTag.equals("item")) {
        			this.currentEvent = new Event();
        		}
        	} else if(eventType == XmlPullParser.END_TAG) {
        		String endTag = xpp.getName();
        		if(endTag.equals("item")) {
        			this.events.add(this.currentEvent);
        		}
        	} else if(eventType == XmlPullParser.TEXT) {
        		if(isValidTag(this.currentTag, this.currentEvent)) {
        			this.currentEvent.addFieldFromRss(this.currentTag, xpp.getText());
        		}
        	}
        	eventType = xpp.next();
        }
        // stop the another thread was loaded to grab data
        if(currentThreads != this.loadingThreads) {
        	return;
        }
        final ListView listV = (ListView) findViewById(R.id.eventsList);
        Event[] eventsList = new Event[this.events.size()];
        this.events.toArray(eventsList);

        final EventsAdapter adapter = new EventsAdapter(this, 0, eventsList);
        //final ArrayAdapter<Event> adapter =  new ArrayAdapter<Event>(this, android.R.layout.simple_list_item_1, android.R.id.text1, eventsList);
        this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if(EventsActivity.this.loadingThreads == 1) {
					listV.setAdapter(adapter);	
				}
			}
		});
    }
    
    static private boolean isValidTag(String tag, Event event) {
    	return     (tag.equals("title") && event.title.equals("N/A"))
    			|| (tag.equals("event_start") && event.startTime.equals("N/A"))
    			|| (tag.equals("event_end") && event.endTime.equals("N/A"))
    			|| (tag.equals("description") && event.description.equals("N/A"))
    			|| (tag.equals("location") && event.location.equals("N/A"))
    			|| (tag.equals("link") && event.link.equals("N/A"))
    			|| (tag.equals("event_date") && event.date.equals("N/A"));
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

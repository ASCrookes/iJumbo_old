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
import android.os.Bundle;
import android.view.Menu;
import android.widget.ArrayAdapter;
import android.widget.ListView;

public class EventsActivity extends Activity implements LoadActivityInterface {

	private Date date;
	private String currentTag;
	private Event currentEvent;
	// events is used to catch the data
	private List <Event> events;
	// data source is what the table uses
	//private List <Event> dataSource;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_events);
        this.date = new Date();
        // the below line calls this.loadData in a background thread
        new Thread(new ActivityLoadThread(this)).start();
        //this.loadData();
        
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_events, menu);
        return true;
    }
    
    public void loadData() {
    	System.out.println("LOADING DATA FOR THE EVENTS");
    	// get the xml
    	
    	String xml = new RequestManager().get(this.getURL());
    	// load it into a stream
    	InputStream inStream = new ByteArrayInputStream(xml.getBytes());
    	try {
    		// parse through it
    		System.out.println("ABOUT TO CALL PARSE THAT ISH");
			this.parseThatIsh(inStream);
		} catch (XmlPullParserException e) {
			System.out.print(e);
		} catch (IOException e) {
			System.out.print(e);
		}
    	System.out.println("DONE LOADING THE EVENTS DATA");
     }
    
    private String getURL() {
    	String url = "https://www.tuftslife.com/occurrences.rss?date=";
    	SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM+d%2'C'+y", Locale.US);
    	url = url + dateFormat.format(this.date);
    	url = "https://www.tuftslife.com/occurrences.rss?date=November+26%2C+2012";
    	return url;
    }
    
    private void parseThatIsh(InputStream inStream) throws XmlPullParserException, IOException {
    	System.out.println("STARTING TO PARSE THAT ISH");
    	XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        factory.setNamespaceAware(true);
        XmlPullParser xpp = factory.newPullParser();
        	
        xpp.setInput(inStream, null);
        int eventType = xpp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
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
        		System.out.println(endTag);
        	} else if(eventType == XmlPullParser.TEXT) {
        		if(isValidTag(this.currentTag, this.currentEvent)) {
        			this.currentEvent.addFieldFromRss(this.currentTag, xpp.getText());
        		}
        	}
        	eventType = xpp.next();
        }
        System.out.println("FINISHED GRABING DATA");
        
        System.out.println(this.events);
        final ListView listV = (ListView) findViewById(R.id.eventsList);
        Event[] eventsList = new Event[this.events.size()];
        this.events.toArray(eventsList);
        final ArrayAdapter<Event> adapter =  new ArrayAdapter<Event>(this, android.R.layout.simple_list_item_1, android.R.id.text1, eventsList);
        this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				System.out.println("ADDING ADAPTER TO THE LIST");
				listV.setAdapter(adapter);			
			}
		});
        //listV.setAdapter(adapter);
        //this.dataSource = this.events;
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

	@Override
	public void stopLoadingUI() {
		// TODO Auto-generated method stub
	}

	@Override
	public void startLoadingUI() {
		// TODO Auto-generated method stub
	}
    
}
package com.ijumboapp;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.Spinner;


public class NewsActivity extends IJumboActivity implements LoadActivityInterface {

	private List <Article> articles;
	private Article currentArticle;
	private String currentTag;
	private Map<String, List<Article> > stories;
	private Date storiesCreated;
	private Map<String, String> urls;
	//private Spinner newsSpinner;
	private Spinner newsSectionsSpinner;
	
    @SuppressWarnings("unchecked")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news);
        ListView lView = (ListView) findViewById(R.id.newsList);
        this.stories = (HashMap<String, List<Article>>) getIntent().getSerializableExtra("newsStories");
        lView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				Intent intent = new Intent(NewsActivity.this, WebActivity.class);
				intent.putExtra("url", NewsActivity.this.articles.get(arg2).link);
				intent.putExtra("title", "News");
				NewsActivity.this.startActivity(intent);
			}
		});
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_news, menu);
        //this sets up the news source spinner
        //this.newsSpinner = (Spinner) menu.findItem(R.id.newsSpinner).getActionView();
        this.newsSectionsSpinner = (Spinner) menu.findItem(R.id.newsSectionSpinner).getActionView();
        this.newsSectionsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				NewsActivity.this.displayDataBasedOnUI();
			}
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
        });

        new Thread(new ActivityLoadThread(this)).start();
        
        return true;
    }
	
	@Override
	public void onBackPressed() {
		Intent resultIntent = new Intent();
		resultIntent.putExtra("newsStories", (Serializable) this.stories);
		setResult(Activity.RESULT_OK, resultIntent);
		finish();
	}
	
    
    public void loadData() {
    	// get the xml
    	List <Article> requestedArticles = this.getStories().get(this.getKeyFromUI());
    	// if this breaks make the below function (shoudl load) return false always
    	if(this.shouldUseSavedArticles() && requestedArticles != null) {
    		final ListView listV = (ListView) findViewById(R.id.newsList);
    		Article[] articlesList = new Article[requestedArticles.size()];
            requestedArticles.toArray(articlesList);
            this.articles = requestedArticles;
            //final ArrayAdapter<Article> adapter =  new ArrayAdapter<Article>(this, android.R.layout.simple_list_item_1, android.R.id.text1, articlesList);
            final NewsAdapter adapter2 = new NewsAdapter(this, R.layout.news_listview_row, articlesList);
            this.runOnUiThread(new Runnable() {
    			@Override
    			public void run() {
    				listV.setAdapter(adapter2);
    			}
    		});
            return;
    	}
    	String xml = new RequestManager().get(this.getURL());
    	if(xml == null) {
    		System.out.println("news got null from the server");
    		return;
    	}
    	// load binary of the xml into a stream
    	InputStream inStream = new ByteArrayInputStream(xml.getBytes());
    	boolean didParse = true;
    	try {
			this.parseThatIsh(inStream);
		} catch (XmlPullParserException e) {
			didParse = false;
		} catch (IOException e) {
			didParse = false;
		}
    	
    	// if it did parse save the articles (this.articles)
    	// into the list of already loaded stories 
    	if(didParse) {
    		String key = this.getKeyFromUI();
    		this.getStories().put(key, this.articles);
    	}
    }
    
    private boolean shouldUseSavedArticles() {
    	// if the data has been around for more than 10 minutes 
    	// (600000 milliseconds) do not use the saved articles
    	return (new Date().getTime() - this.storiesCreated.getTime() < 600000);
    }
    
    private void displayDataBasedOnUI() {
    	new Thread(new ActivityLoadThread(this)).start();
    }
    
    // change this so it grabs stuff from the UI and gets the correct url
    // put in big if else instead of grabbing the url from a hashtable
    private String getURL() {
    	String urlKey = this.getKeyFromUI();
    	// the getter will create the hash table if it does not exist yet
    	// then return the url from that hash table
    	return this.getUrls().get(urlKey);
    }
    
    private String getKeyFromUI() {
    	// Format: NewsSource-NewsSection
    	return /*this.newsSpinner.getSelectedItem().toString()*/
    			"Daily" + "-" + 
			   this.newsSectionsSpinner.getSelectedItem().toString();
    }
    
    private void parseThatIsh(InputStream inStream) throws XmlPullParserException, IOException {
    	XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        factory.setNamespaceAware(true);
        XmlPullParser xpp = factory.newPullParser();
        xpp.setInput(inStream, null);
        int eventType = xpp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
        	if(eventType == XmlPullParser.START_DOCUMENT) {
        		this.articles = new ArrayList<Article>();
        		this.currentArticle = new Article();
        		if(xpp.getName() != null && xpp.getName().equals("thumbnail")) {
        			//this.currentArticle.addFieldFromRss(, value)
        		}
        	} else if(eventType == XmlPullParser.START_TAG) {
        		this.currentTag = xpp.getName();
        		if(this.currentTag.equals("item")) {
        			this.currentArticle = new Article();
        		} else if(this.currentTag.equals("media:thumbnail")) {
        		}
        	} else if(eventType == XmlPullParser.END_TAG) {
        		String endTag = xpp.getName();
        		if(endTag.equals("item")) {
        			this.articles.add(this.currentArticle);
        		}
        	} else if(eventType == XmlPullParser.TEXT) {
        		if(isValidTag(this.currentTag, this.currentArticle)) {
        			this.currentArticle.addFieldFromRss(this.currentTag, xpp.getText());
        		}
        	}
    		if(xpp.getName() != null && xpp.getName().equals("thumbnail") && xpp.getAttributeCount() > 1) {
    			this.currentArticle.addFieldFromRss("thumbnail", xpp.getAttributeValue(null, "url"));
    		}
        	eventType = xpp.next();
        }
        final ListView listV = (ListView) findViewById(R.id.newsList);
        Article[] articlesList = new Article[this.articles.size()];
        this.articles.toArray(articlesList);
        for(int i = 0; i < articlesList.length; i++) {
        	articlesList[i].downloadImage();
        }
        final NewsAdapter adapter = new NewsAdapter(this, R.layout.news_listview_row, articlesList);
        this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				listV.setAdapter(adapter);
			}
		});
        
        //this.dataSource = this.events;
    }
    
    static private boolean isValidTag(String tag, Article article) {
    	return     (tag.equals("title") && article.title.equals("N/A"))
    			|| (tag.equals("link") && article.link.equals("N/A"))
    			|| (tag.equals("author") && article.author.equals("N/A"))
    			|| (tag.equals("media:thumbnail") && article.imageURL.equals("N/A"));
    }

	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				ProgressBar pBar = (ProgressBar) findViewById(R.id.newsPD);
				pBar.setVisibility(View.INVISIBLE);
				NewsActivity.this.newsSectionsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
					@Override
					public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
						NewsActivity.this.displayDataBasedOnUI();
					}
					@Override
					public void onNothingSelected(AdapterView<?> arg0) {}
		        });
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				ProgressBar pBar = (ProgressBar) findViewById(R.id.newsPD);
				pBar.setVisibility(View.VISIBLE);
				NewsActivity.this.newsSectionsSpinner.setOnItemSelectedListener(null);
			}
		});
	}

	public Map<String, List<Article> > getStories() {
		if(stories == null) {
			stories = new HashMap< String, List<Article> >();
			this.storiesCreated = new Date();
		}
		return stories;
	}
	
	// remove this and make a switch over the values and just return a string
	// no need for a data structure to do this
	public Map<String, String> getUrls() {
		if(urls == null) {
			urls = new HashMap<String, String>();
			// The Daily
			urls.put("Daily-Main", "http://www.tuftsdaily.com/se/tufts-daily-rss-1.445827");
			urls.put("Daily-News", "http://www.tuftsdaily.com/se/tufts-daily-news-rss-1.445867");
			urls.put("Daily-Features", "http://www.tuftsdaily.com/se/tufts-daily-features-rss-1.445868");
			urls.put("Daily-Arts", "http://www.tuftsdaily.com/se/tufts-daily-arts-rss-1.445870");
			urls.put("Daily-Op-Ed", "http://www.tuftsdaily.com/se/tufts-daily-op-ed-rss-1.445869");
			urls.put("Daily-Sports", "http://www.tuftsdaily.com/se/tufts-daily-sports-rss-1.445871");
			// The Observer
			/*
			urls.put("Observer-Arts", "http://tuftsobserver.org/category/arts-culture/feed");
			urls.put("Observer-Campus", "http://tuftsobserver.org/category/campus/feed");
			urls.put("Observer-News", "http://tuftsobserver.org/category/news-features/feed");
			urls.put("Observer-Off Campus", "http://tuftsobserver.org/category/off-campus/feed");
			urls.put("Observer-Opinion", "http://tuftsobserver.org/category/opinion/feed");
			urls.put("Observer-Poetry", "http://tuftsobserver.org/category/poetry-prose/feed");
			urls.put("Observer-Extras", "http://tuftsobserver.org/category/extras/feed");
			*/
		}
		return urls;
	}

	
}

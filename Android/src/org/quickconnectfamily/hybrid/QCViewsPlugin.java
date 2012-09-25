package org.quickconnectfamily.hybrid;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.quickconnect.QuickConnect;
import org.quickconnectfamily.hybrid.QCAndroid;
import org.quickconnectfamily.hybrid.QCPlugin;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class QCViewsPlugin {
	
	private static HashMap<String,Class> viewTypeMap;
	public static void init() {
		/*
		 * Put supported view types in the viewTypeMap.
		 * They should inherit from the base View type and have a constructor
		 * formatted Constructor(Context, HashMap). 
		 * The HashMap will contain settings for the view.
		 */
		viewTypeMap = new HashMap<String,Class>();
		viewTypeMap.put("Web", QCWebView.class);
		viewTypeMap.put("Map", QCMapView.class);
		viewTypeMap.put("Container", QCViewGroup.class);
	}
	/*
	 * It adds a view of any mapped type by calling its constructor.  To map another 
	 * view type add a key String for the type and the View's Class as the value to 
	 * the viewTypeMap.
	 */
	public static void removeView(QCAndroid theContext, View viewToModify, String id, HashMap settings){
		// is viewToModify a ViewGroup
		if(viewToModify.getClass() == QCViewGroup.class){
			  // if so, call removeChildViews( theContext, viewToModify, String id)
			QCViewsPlugin.removeChildViews( theContext, (QCViewGroup)viewToModify, id);
		}
		// lookup parent
		   // if we have settings.get("parent")
		   // find that
		QCAndroid instance = QCAndroid.getInstance();
		if(settings.get("parentId") != null || ((String)settings.get("parentId")).length() != 0){
			QCViewGroup parent = (QCViewGroup) instance.getView((String) settings.get("parentId"));
			parent.removeView(viewToModify);
			HashMap pm = instance.viewStorage.get(settings.get("parentId"));
			ArrayList pl = (ArrayList) pm.get("children");
			pl.remove(id);
		}
		   // otherwise parent is layout
		else{
			instance.layout.removeView(viewToModify);
		}
		// remove view from its parent (which may be layout)
		// remove id from HashMap
		instance.viewStorage.remove(id);
	}
	
	private static void removeChildViews( QCAndroid theContext, QCViewGroup parentView, String jsid ){
		// This method recursively removes the entries for child views of the view referred to by jsid from
		// QCAndroid theContext.viewStorage. Then removes the entry for jsid itself.
		HashMap viewInfo = theContext.viewStorage.get( jsid );
		if( viewInfo.get("children") != null ){
			ArrayList<String> children = (ArrayList<String>) viewInfo.get("children");
			// get iterator for array list
			Iterator i = children.iterator();
			// cycle through iterator
			while( i.hasNext() ){
				// recursively Call removeFromHashMap() for string returned by i.next().
				String childId = (String)i.next();
				View childView = theContext.getView(childId);
				if( childView.getClass() == QCViewGroup.class ){
					// if the childView is a ViewGroup, remove it's children
					QCViewsPlugin.removeChildViews( theContext, (QCViewGroup)childView, childId );
				}
				// then remove the childView
				parentView.removeView(childView);
				// Clean up hashMap
				theContext.viewStorage.remove( childId );
				// then i.remove() to remove it from the ArrayList (not needed)
			}
		}
		
	}
	
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public static View addViewForType(QCAndroid theContext, String aType, HashMap settings) throws SecurityException, NoSuchMethodException, IllegalArgumentException, InstantiationException, IllegalAccessException, InvocationTargetException{
		Class aViewClass =  viewTypeMap.get(aType);
		Constructor constructor = aViewClass.getConstructor(new Class[]{QCAndroid.class, HashMap.class});
		Object[] args = new Object[] { theContext, settings };
		View theView = (View)constructor.newInstance(args);
		String parentId = (String) settings.get("parentId");
		if(parentId != null && parentId.length() != 0){
			try{
				QCViewGroup addTo = (QCViewGroup) theContext.getView(parentId);
				HashMap hm = new HashMap();
				hm.put("parent",parentId);
				HashMap pm = theContext.viewStorage.get(parentId);
				if(pm.get("children") == null){
					ArrayList<String> children = new ArrayList<String>();
					children.add((String) settings.get("id"));
					 pm.put("children", children);
				}
				else{
					((ArrayList<String>) pm.get("children")).add((String) settings.get("id"));
				}
				Date now = new Date();
				long id = now.getTime();
				Integer idi = (int) id;
				theView.setId(idi);
				// storing the view's jsId in the tag for later use in reporting back to js from WebViewClient, WebChromeClient, etc.
				// NOT for findViewByTag(), which we don't use anymore
				theView.setTag((String) settings.get("id"));
				hm.put("id",theView.getId());
				theContext.viewStorage.put((String) settings.get("id"),hm);
				addTo.addView(theView);
			}
			
			catch(Exception e){
				if(e.getClass() == ClassCastException.class){
					System.out.println("Cannot add view to non-ViewGroup view");
				}
				else{
				System.out.println(e.getMessage());
				}
			}
		}
		else{
			HashMap hm = new HashMap();
			hm.put("parent",parentId);
			Date now = new Date();
			long id = now.getTime();
			Integer idi = (int) id;
			theView.setId(idi);
			hm.put("id",theView.getId());
			theContext.viewStorage.put((String) settings.get("id"),hm);	
			theContext.addView(theView);
		}
		
		return theView;
	}

}

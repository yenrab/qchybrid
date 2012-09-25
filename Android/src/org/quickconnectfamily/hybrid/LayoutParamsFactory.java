package org.quickconnectfamily.hybrid;

import java.util.HashMap;

import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;

public class LayoutParamsFactory {
	public static FrameLayout.LayoutParams build(HashMap<String,Object> settings){
		/*
		 * retrieve configuration values
		 */
		long left = 0;
		long top = 0;
		long right = 0;
		long bottom = 0;
		long height = 0;
		long width = 0;
		left = (Long) settings.get("left");

		top = (Long) settings.get("top");
		//We need to account for optional settings, such as right and bottom margins
		if(settings.containsKey("right")){
			right = (Long)settings.get("right");
		}
		if(settings.containsKey("bottom")){
			bottom = (Long) settings.get("bottom");
		}
		//height and width are currently available in two flavors: pixel sizing or fill-parent.
		if(settings.get("height").equals("fill_parent")){
			height = LayoutParams.FILL_PARENT;
		}
		else{
			height = (Long) settings.get("height");
		}
		if(settings.get("width").equals("fill_parent")){
			width = LayoutParams.FILL_PARENT;
		}
		else{
			width = (Long) settings.get("width");
		}
		LayoutParams p = new FrameLayout.LayoutParams((int)width,(int)height,0);
		p.setMargins((int)left, (int)top, (int)right, (int)bottom);
		return p;
	}
}

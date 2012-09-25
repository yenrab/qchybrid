package org.quickconnectfamily.hybrid;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.google.android.maps.GeoPoint;
import com.google.android.maps.MapController;
import com.google.android.maps.MapView;
import com.google.android.maps.Overlay;
import com.google.android.maps.OverlayItem;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.Drawable;

public class QCMapView extends MapView{

	public QCMapView(QCAndroid context, HashMap settings) {
		super(context, "Insert Maps API key here");
		// TODO Auto-generated constructor stub
	}
	public Object configure(HashMap settings) {
		
		this.setLayoutParams(LayoutParamsFactory.build(settings));
		
		String clickable = (String) settings.get("clickable");
		if(clickable != null){
			this.setClickable(Boolean.parseBoolean(clickable));
		}
		
		String zoomcontrols = (String) settings.get("showZoomControls");
		if(zoomcontrols != null){
			this.setBuiltInZoomControls(Boolean.parseBoolean(zoomcontrols));
		}
		
		String maptype = (String) settings.get("mapType");
		if(maptype != null){
			if(maptype.equals("street")){
				this.setSatellite(false);
			}
			else if(maptype.equals("satellite") || maptype.equals("hybrid")){
				this.setSatellite(true);
			}
		}
		String color = (String) settings.get("backgroundColor");
		if(color != null){
			if(color.equals("clear") || color.equals("transparent")){
				this.setBackgroundColor(Color.TRANSPARENT);
			}
			else if(color.equals("white")){
				this.setBackgroundColor(Color.WHITE);
			}
			else if(color.equals("black")){
				this.setBackgroundColor(Color.BLACK);
			}
		}
		ArrayList<HashMap> overlays = (ArrayList) settings.get("overlays");
		List<Overlay> mapOverlays = this.getOverlays();
		Drawable drawable = getResources().getDrawable(R.drawable.marker);
		//I set them to physically impossible values in their respective ranges, to force change.
		double maxlat = -91;
		double minlat = 91;
		double maxlon = -181;
		double minlon = 181;
		for(int i = 0; i < overlays.size(); i++){
			HashMap thisOverlay = (HashMap) overlays.get(i);
			if(thisOverlay.get("type").equals("locations")){
				QCItemizedOverlay temp = new QCItemizedOverlay(drawable, this);
				ArrayList<HashMap> points = (ArrayList) thisOverlay.get("points");
				for(int j = 0; j < points.size(); j++){
					HashMap thisPoint = points.get(j);
					double lat = (Double) thisPoint.get("latitude");
					double lon = (Double) thisPoint.get("longitude");
					if(lat < minlat){
						minlat = lat;
					}
					if(lat > maxlat){
						maxlat = lat;
					}
					if(lon < minlon){
						minlon = lon;
					}
					if(lon > maxlon){
						maxlon = lon;
					}
					GeoPoint thisGeo = new GeoPoint((int)(lat*1E6),(int)(lon*1E6));
					String title = (String) thisPoint.get("title");
					String description = (String) thisPoint.get("description");
					OverlayItem thisItem = new OverlayItem(thisGeo,title,description);
					temp.addOverlay(thisItem);
				}
				mapOverlays.add(temp);
			}
		}
		final MapController mc = this.getController();
		if(settings.get("max") != null || settings.get("min") != null){
			HashMap max = (HashMap) settings.get("max");
			HashMap min = (HashMap) settings.get("min");
			maxlat = (Double) max.get("latitude");
			minlat = (Double) min.get("latitude");
			maxlon = (Double) max.get("longitude");
			minlon = (Double) min.get("longitude");
		}
		mc.animateTo(new GeoPoint(((int)(maxlat*1E6) + (int)(minlat*1E6))/2,(((int)(maxlon*1E6) + (int)(minlon*1E6))/2 )));
		mc.zoomToSpan((int)((maxlat-minlat)*1E6),(int)((maxlon-minlon)*1E6));
		

		// return our tag, just to say "configuration complete".
		return this.getTag();
	}

}

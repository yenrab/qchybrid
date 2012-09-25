package org.quickconnectfamily.hybrid.commandobjects;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;
import org.quickconnectfamily.hybrid.QCAndroid;

import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.LinearInterpolator;

import android.view.animation.Interpolator;


public class AnimateViewVCO implements ControlObject {
	private Animation anim;
	private Interpolator accel;
	@SuppressWarnings("unchecked")
	@Override
	public Object handleIt(HashMap<String, Object> parameters) {

		QCAndroid activity = (QCAndroid) parameters.get("activity");
		ArrayList<Object> passedParameters = (ArrayList<Object>)parameters.get("parameters");
		HashMap<Object, Object> configuration = (HashMap<Object, Object>) passedParameters.get(0);
		View theView = activity.getView((String) configuration.get("id"));
		
		HashMap<String, Object> animationSettings = (HashMap<String, Object>)passedParameters.get(1);
		
		String curve    = (String)animationSettings.get("curve");
		String duration = (String)animationSettings.get("duration");
		String start    = (String)animationSettings.get("start");
		String end      = (String)animationSettings.get("end");
		
		//HashMap<String, String> properties = (HashMap<String, String>)animationSettings.get("properties");
		
		//{curve=bounce, duration=1000, properties={}, start=left, end=in}
		String accelType = (String) parameters.get("curve");
		if(start.equals("in") && end.equals("right")){
			anim = AnimationUtils.makeOutAnimation(activity, true);
		}
		else if(start.equals("in") && end.equals("left")){
			anim = AnimationUtils.makeOutAnimation(activity, false);
		}
		else if(start.equals("right") && end.equals("in")){
			anim = AnimationUtils.makeInAnimation(activity,false);
		}
		else if(start.equals("left") && end.equals("in")){
			anim = AnimationUtils.makeInAnimation(activity,true);
		}
		else if(start.equals("out") && end.equals("in")){
			anim = new AlphaAnimation((long)0.0,(long)1.0);
		}
		else if(start.equals("in") && end.equals("out")){
			anim = new AlphaAnimation((long)1.0,(long)0.0);
		}
		else{
			Log.d("QCAndroid","Animation given is invalid.");
			return null;
		}
		if(accelType.equals("linear")){
			accel = new LinearInterpolator();
		}
		else if(accelType.equals("bounce")){
			try {
				Class interpolatorClass = Class.forName("android.view.animation.BounceInterpolator");
				if(interpolatorClass != null){
					Class[] emptyParamTypeList = new Class[0];
					Constructor interpolatorConstructor = interpolatorClass.getDeclaredConstructor(emptyParamTypeList);
					Object[] emptyParamList = new Object[0];
					accel = (Interpolator)interpolatorConstructor.newInstance(emptyParamList);
				}
			} catch (Exception e) {
				System.out.println("BounceInterpolator not available in this version of Android.  If you wish to use this you must run on version 1.6");
			}
		}
		else if(accelType.equals("easeIn")){
			accel = new AccelerateInterpolator();
		}
		else if(accelType.equals("easeOut")){
			accel = new DecelerateInterpolator();
		}
		else if(accelType.equals("overshoot")){
			try{
				Class interpolatorClass = Class.forName("android.view.animation.OvershootInterpolator");
				if(interpolatorClass != null){
					Class[] emptyParamTypeList = new Class[0];
					Constructor interpolatorConstructor = interpolatorClass.getDeclaredConstructor(emptyParamTypeList);
					Object[] emptyParamList = new Object[0];
					accel = (Interpolator)interpolatorConstructor.newInstance(emptyParamList);
				}
			} catch (Exception e) {
				System.out.println("BounceInterpolator not available in this version of Android.  If you wish to use this you must run on version 1.6");
			}
		}
		else if(accelType.equals("anticipate")){
			try{
			Class interpolatorClass = Class.forName("android.view.animation.AnticipateInterpolator");
				if(interpolatorClass != null){
					Class[] emptyParamTypeList = new Class[0];
					Constructor interpolatorConstructor = interpolatorClass.getDeclaredConstructor(emptyParamTypeList);
					Object[] emptyParamList = new Object[0];
					accel = (Interpolator)interpolatorConstructor.newInstance(emptyParamList);
				}
			} catch (Exception e) {
				System.out.println("BounceInterpolator not available in this version of Android.  If you wish to use this you must run on version 1.6");
			}
		}
		else if(accelType.equals("anticipateovershoot")){
			try{
				Class interpolatorClass = Class.forName("android.view.animation.AnticipateOvershootInterpolator");
				if(interpolatorClass != null){
					Class[] emptyParamTypeList = new Class[0];
					Constructor interpolatorConstructor = interpolatorClass.getDeclaredConstructor(emptyParamTypeList);
					Object[] emptyParamList = new Object[0];
					accel = (Interpolator)interpolatorConstructor.newInstance(emptyParamList);
				}
			} catch (Exception e) {
				System.out.println("BounceInterpolator not available in this version of Android.  If you wish to use this you must run on version 1.6");
			}
		}
		else if(accelType.equals("easeInEaseOut")){
			accel = new AccelerateDecelerateInterpolator();
		}
		else{
			accel = new LinearInterpolator();
		}
		anim.setInterpolator(accel);
		if((Long)animationSettings.get("duration") != null){
			anim.setDuration((Long)animationSettings.get("duration"));
		}
		theView.startAnimation(anim);
		return null;
	}

}

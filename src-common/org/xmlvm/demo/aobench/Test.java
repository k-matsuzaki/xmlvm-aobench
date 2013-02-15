package org.xmlvm.demo.aobench;

import org.xmlvm.iphone.CFType;
import org.xmlvm.iphone.NSString;

public class Test {
	public static double sqrt(double x) {
		return Math.sqrt(x);
	}
	
	public static CFType dummy(NSString str) {
		return null;
	}
	
	public static interface Hoge<T> {
		T get();
		void set(T t);
	}
	
	public static class HogeParent {
		public Object get() {
			return Integer.valueOf(10);
		}
	}
	public static class HogeImpl extends HogeParent implements Hoge<String> {

		public String get() {
			return "ABC";
		}

		public void set(String t) {
		}
	}
}

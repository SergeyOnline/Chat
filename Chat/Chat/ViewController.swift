//
//  ViewController.swift
//  Chat
//
//  Created by Сергей on 17.09.2021.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		printViewMethod()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		printViewMethod()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		printViewMethod()
	}

	override func viewWillLayoutSubviews() {
		 super.viewWillLayoutSubviews()
		// The default implementation of this method does nothing.
		// No need to call the parent (super) method?

		printViewMethod()
	}
	
	override func viewDidLayoutSubviews() {
		 super.viewDidLayoutSubviews()
		// The default implementation of this method does nothing.
		// No need to call the parent (super) method?

		printViewMethod()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		
		printViewMethod()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		
		printViewMethod()
	}
	
	/**
	Prints the method invoked by the view controller lifecycle change
	
	- parameter sender: Method called when the state of the View changes.  Default value - #function
	
	# Notes: #
	1. Method only works with Build Configuration - Debug
	2. To use it, you need to add the DEBUG_LOG_VC_LIFE argument to the schema settings
	*/
	private func printViewMethod(sender: String = #function) {
		#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_VC_LIFE") {
			print(sender)
		}
		#endif
	}

}

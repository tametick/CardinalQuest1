package cq;

import flash.display.BitmapData;

import haxel.HxlButton;
import haxel.HxlButtonContainer;
import haxel.HxlDialog;
import haxel.HxlGradient;
import haxel.HxlGraphics;
import haxel.HxlSlidingDialog;
import haxel.HxlSprite;
import haxel.HxlText;
import haxel.HxlTextContainer;

class GameUI extends HxlDialog {

	// Main UI containers
	var leftButtons:HxlButtonContainer;
	var rightButtons:HxlButtonContainer;
	var statusDialog:HxlTextContainer;

	// View state panels
	var panelMap:HxlSlidingDialog;
	var panelInventory:CqInventoryDialog;
	var panelCharacter:HxlSlidingDialog;
	var panelLog:HxlSlidingDialog;

	// Left side button panel
	var btnMainView:HxlButton;
	var btnMapView:HxlButton;
	var btnInventoryView:HxlButton;
	var btnCharacterView:HxlButton;
	var btnLogView:HxlButton;

	// State & helper vars
	var currentPanel:HxlSlidingDialog;

	public override function new() {
		super(0, 0, HxlGraphics.width, HxlGraphics.height);

		currentPanel = null;
		var self = this;

		// highlight button for current view (if any)

		/**
		 * Create and init main containers
		 **/
		leftButtons = new HxlButtonContainer(0, 100, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		leftButtons.setBackgroundColor(0x99555555, 10);
		add(leftButtons);

		rightButtons = new HxlButtonContainer(HxlGraphics.width-84, 100, 84, 380, HxlButtonContainer.VERTICAL, HxlButtonContainer.TOP_TO_BOTTOM, 10, 10);
		//rightButtons.setBackgroundColor(0x88555555);
		add(rightButtons);

		statusDialog = new HxlTextContainer( 10, 10, 620, 80 );
		statusDialog.setFormat("Geo", 18, 0xffffff, "left", 0x000000);
		statusDialog.setColorStep(true);
		statusDialog.setBackgroundSprite(HxlGradient.Rect(620, 40, [0xffffff, 0xffffff, 0xffffff], [0, 128, 255], [0.5, 0.0, 0.0], Math.PI/2, 20));
		add(statusDialog);

		/**
		 * View state panels
		 **/
		panelMap = new HxlSlidingDialog(84, 0, 472, 480);
		panelMap.setBackgroundColor(0xff9A9DBC);
		add(panelMap);
		panelInventory = new CqInventoryDialog(84, 0, 472, 480);

		panelInventory.setBackgroundColor(0xffBC9A9A);
		add(panelInventory);

		panelCharacter = new HxlSlidingDialog(84, 0, 472, 480);
		panelCharacter.setBackgroundColor(0xff9ABC9D);
		add(panelCharacter);

		panelLog = new HxlSlidingDialog(84, 0, 472, 480);
		panelLog.setBackgroundColor(0xffBCB59A);
		add(panelLog);

		/**
		 * Left side panel buttons
		 **/
		btnMainView = new HxlButton(0, 0, 64, 64);
		btnMainView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMainView.loadText(new HxlText(0, 23, 64, "Main", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnMainView.setCallback(function() {
			self.showPanel(null);
		});

		leftButtons.addButton(btnMainView);

		btnMapView = new HxlButton(0, 0, 64, 64);
		btnMapView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnMapView.loadText(new HxlText(0, 23, 64, "Map", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnMapView.setCallback(function() {
			self.showPanel(self.panelMap);
		});
		leftButtons.addButton(btnMapView);

		btnInventoryView = new HxlButton(0, 0, 64, 64);
		btnInventoryView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnInventoryView.loadText(new HxlText(0, 23, 64, "Inv", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnInventoryView.setCallback(function() {
			self.showPanel(self.panelInventory);
		});

		leftButtons.addButton(btnInventoryView);

		btnCharacterView = new HxlButton(0, 0, 64, 64);
		btnCharacterView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnCharacterView.loadText(new HxlText(0, 23, 64, "Char", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnCharacterView.setCallback(function() {
			self.showPanel(self.panelCharacter);
		});

		leftButtons.addButton(btnCharacterView);

		btnLogView = new HxlButton(0, 0, 64, 64);
		btnLogView.setBackgroundColor(0xff999999, 0xffcccccc);
		btnLogView.loadText(new HxlText(0, 23, 64, "Log", true, "Geo").setFormat("Geo", 18, 0xffffff, "center", 0x010101));
		btnLogView.setCallback(function() {
			self.showPanel(self.panelLog);
		});

		leftButtons.addButton(btnLogView);

		/**
		 * Right side panel buttons
		 **/
		// these are temporary
		var btn1:HxlButton = new HxlButton(0, 0, 64, 64);
		btn1.setBackgroundColor(0xff999999, 0xffcccccc);
		rightButtons.addButton(btn1);

		var btn2:HxlButton = new HxlButton(0, 0, 64, 64);
		btn2.setBackgroundColor(0xff999999, 0xffcccccc);
		rightButtons.addButton(btn2);

		var btn3:HxlButton = new HxlButton(0, 0, 64, 64);
		btn3.setBackgroundColor(0xff999999, 0xffcccccc);
		rightButtons.addButton(btn3);

		var btn4:HxlButton = new HxlButton(0, 0, 64, 64);
		btn4.setBackgroundColor(0xff999999, 0xffcccccc);
		rightButtons.addButton(btn4);

		var btn5:HxlButton = new HxlButton(0, 0, 64, 64);
		btn5.setBackgroundColor(0xff999999, 0xffcccccc);
		rightButtons.addButton(btn5);

	}

	function showPanel(Panel:HxlSlidingDialog):Void {
		if ( Panel == null ) {
			if ( currentPanel != null ) {
				var self = this;
				currentPanel.hide(function() { self.currentPanel = null; });
			}
		} else {
			if ( currentPanel == null ) {
				currentPanel = Panel;
				Panel.show();
			} else {
				var self = this;
				if ( currentPanel != Panel ) {
					currentPanel.hide(function() {
						self.currentPanel = Panel;
						self.currentPanel.show();
					});
				} else {
					currentPanel.show();
				}
			}
		}
	}

}

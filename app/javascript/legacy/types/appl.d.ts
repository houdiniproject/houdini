// License: LGPL-3.0-or-later

// The old appl interface. Just doing so this is easier to migrate
export default interface Appl {

	def(key:string, value:unknown):void;
	def_lazy
	is_loading():void;
	notify(notification:string):void;
	open_modal:(modalId:string) => Appl;

	redirect():void;
	reload():void;

	prev_elem(elem:HTMLElement):HTMLElement;

	wizard: {
		advance(stepName:string):void;
	};
	

}
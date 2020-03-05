var Fish = (function() {
	return {
		isFishable: function(conditions, zoneName) {
			// console.log(conditions);
			// console.log(zoneName);
			var h = gt.time.melodysGetTime();
			var sky = gt.skywatcher.getViewModel()[zoneName];
			// console.log(h);
			// console.log(sky);
			if(conditions.start_time || conditions.curr_weathers) {
				// console.log("For fish " + f + " there's a restriction");
				var wok = true;
				var tok = true;
				var dok = true;
				if(conditions.curr_weathers) {
					wok = conditions.curr_weathers.includes(sky[1]);
				}
				if(conditions.prev_weathers) {
					tok = conditions.prev_weathers.includes(sky[0]);
				}
				if(conditions.start_time && conditions.end_time) {
					var currentHour = parseInt(h.substring(0,2), 10);
					if(conditions.end_time > conditions.start_time) {
						dok = currentHour >= conditions.start_time && currentHour < conditions.end_time;
					} else {
						dok = currentHour >= conditions.start_time || currentHour < conditions.end_time;
					}
				}
				return wok && dok && tok;
			} else {
				// no restrictions on fish, always fishable
				return true;
			}
		}
	};
})();
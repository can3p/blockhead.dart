exports.pad = function(str, chr) {
    return (chr + str).substr(-2);
}

exports.monthName = function(idx) {
    var months = [ "Январь", "Февраль", "Март", "Апрель", "Май"
      , "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];
    return months[idx];
}

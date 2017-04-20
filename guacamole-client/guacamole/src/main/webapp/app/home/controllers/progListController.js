angular.module('home').controller('progListController', ['$scope', function($scope) {
  $scope.runButton = "images/grey_run_button.png";
  $scope.picturePath = "images/";
  $scope.progListItems = {
    'example': [
        {
          id: "distrib.py",
          name: "Python Distribute",
          details: "Description: clicking on the canvas adds a turtle; all the turtles will distribute themselves evenly across the canvas.",
          image: $scope.picturePath + "distrib_py.png",
          instructions: "Simply click on any blank area of the background to place a turtle there.  The turtles will then automatically try to  distribute themselves in the space.",
          author: "Victor Norman",
          date: "Before Fall 2016"
        }
    ]
  };
}]);

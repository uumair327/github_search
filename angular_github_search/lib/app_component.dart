import 'package:angular_github_search/src/github_search.dart';
import 'package:ngdart/angular.dart';

@Component(
  selector: 'my-app',
  template: '<search-form></search-form>',
  directives: [SearchFormComponent],
)
class AppComponent {
  // Clean Architecture initialization happens in the search form component
}

import 'jquery-ujs'
import '../src/notifier/error_notifier'
import '../src/notifier/success_notifier'
import '../src/form/form_controller'
import '../src/user/hub/posts/post'
import ReactRailsUJS from 'react_ujs';

const componentRequireContext = require.context("components", true);

ReactRailsUJS.useContext(componentRequireContext);

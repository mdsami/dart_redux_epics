import 'dart:async';
import 'package:redux/redux.dart';
import 'package:redux_epics/combined_epic.dart';
import 'package:redux_epics/epic_middleware.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

main() {
  group('Epic Middleware', () {
    test('accept an Epic that transforms one Action into another', () {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new Fire1Epic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      expect(store.state, equals([new Fire1(), new Action1()]));
    });

    test('can combine Epics', () {
      var reducer = new ListOfActionsReducer();
      var epic = new CombinedEpic<List<Action>, Action>(
          [new Fire1Epic(), new Fire2Epic()]);
      var epicMiddleware = new EpicMiddleware(epic);
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(store.state,
          equals([new Fire1(), new Action1(), new Fire2(), new Action2()]));
    });

    test('work with async epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new FireUntilEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Fire1(), new Action1()]));
    });

    test('work with takeUntil async epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new FireUntilEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Fire1(), new Fire2()]));
    });

    test('can replace the current Epic', () {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new Fire1Epic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(store.state, equals([new Fire1(), new Action1(), new Fire2()]));

      epicMiddleware.replaceEpic(new Fire2Epic());

      store.dispatch(new Fire1());
      store.dispatch(new Fire2());

      expect(
          store.state,
          equals([
            new Fire1(),
            new Action1(),
            new Fire2(),
            new Fire1(),
            new Fire2(),
            new Action2()
          ]));
    });

    test('can fire multiple events from epics', () async {
      var reducer = new ListOfActionsReducer();
      var epicMiddleware = new EpicMiddleware(new FireTwoActionsEpic());
      var store = new Store<List<Action>, Action>(reducer,
          initialState: [], middleware: [epicMiddleware]);

      store.dispatch(new Fire1());

      await new Future.delayed(new Duration(milliseconds: 1));

      expect(store.state, equals([new Fire1(), new Action1()]));

      await new Future.delayed(new Duration(milliseconds: 10));

      expect(store.state, equals([new Fire1(), new Action1(), new Action2()]));
    });
  });
}
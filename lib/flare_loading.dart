library flare_loading;

import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';

class FlareLoading extends StatefulWidget {
  final String name;
  final Function(dynamic data) onSuccess;
  final Function(dynamic error, dynamic stacktrace) onError;
  final double width;
  final double height;
  final Alignment alignment;
  final Future Function() until;
  final String loopAnimation;
  final String endAnimation;
  final String startAnimation;
  final bool isLoading;

  const FlareLoading({
    Key key,
    @required this.name,
    @required this.onSuccess,
    @required this.onError,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.until,
    this.loopAnimation,
    this.endAnimation,
    this.startAnimation,
    this.isLoading,
  }) : super(key: key);

  @override
  _FlareLoadingState createState() => _FlareLoadingState();
}

class _FlareLoadingState extends State<FlareLoading> with FlareController {
  ActorAnimation _start, _loading, _complete;
  double _animationTime = 0.0;
  dynamic _data; //save data from the future for the callback
  dynamic _error; //save error from the future for the callback
  dynamic _stack; //save stack from the future for the callback
  bool _isLoading = true; //bool to know if we're still processing
  bool _isSuccessful = false; //bool to know if the until future is successful
  bool _isCompleted = false; //bool to know if endAnimation is finished
  bool _isIntroFinished = false; //bool to know if startAnimation is finished

  @override
  void initState() {
    _isLoading = widget.isLoading ?? true;
    _processCallback();
    super.initState();
  }

  @override
  void didUpdateWidget(FlareLoading oldWidget) {
    if (widget.isLoading != null && widget.isLoading != oldWidget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
        if (_isLoading) {
          _isCompleted = false;
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
        alignment: widget.alignment,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: FlareActor(
            widget.name,
            controller: this,
            callback: (_) => print('finished'),
          ),
        ),
      ),
    );
  }

  Future _processCallback() async {
    if (widget.until == null) {
      _isSuccessful = true;//based on boolean field we're always sucessful
    } else {
      try {
        _data = await widget.until();
        _isSuccessful = true;
      } catch (err, stack) {
        _error = err;
        _stack = stack;
        _isSuccessful = false;
      }
      setState(() {
        _isLoading = false;
      });
      if (_loading == null && _complete == null && _isIntroFinished || _isCompleted) {
        _finished();
      }
    }
  }

  _finished() {
    if (!_isLoading) {
      if (_isSuccessful) {
        widget.onSuccess(_data);
      } else {
        widget.onError(_error, _stack);
      }
    }
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _animationTime += elapsed;

    if (!_isIntroFinished && _start != null) {
      if (_animationTime < _start.duration) {
        // finish start animation
        _start.apply(_animationTime, artboard, 1.0);
        return true;
      } else {
        //start animation finished
        _isIntroFinished = true;
        if (_loading == null && _complete == null) {
          _isLoading = false;
          _finished();
          return false; // if there another animation to continue to return false
        }
      }
    }

    if (_isLoading && _loading != null) {
      // Still loading...
      _animationTime %= _loading.duration;
      _loading.apply(_animationTime, artboard, 1.0);
    } else if (_loading != null && _animationTime < _loading.duration) {
      // Complete, but need to finish loading animation...
      _loading.apply(_animationTime, artboard, 1.0);
    } else if (_complete == null) {
      _isLoading = false;
      _finished();
      return false;
    } else if (!_isCompleted) {
      // Chain completion animation
      double completeTime = _animationTime - (_loading ?? _start).duration;
      _complete.apply(completeTime, artboard, 1.0);
      if (completeTime >= _complete.duration) {
        // Notify we're done and stop advancing.
        _isCompleted = true;
        _isLoading = false;
        _finished();
        return false;
      }
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    if (widget.startAnimation != null) {
      _start = artboard.getAnimation(widget.startAnimation);
    }
    if (widget.loopAnimation != null) {
      _loading = artboard.getAnimation(widget.loopAnimation);
    }
    if (widget.endAnimation != null) {
      _complete = artboard.getAnimation(widget.endAnimation);
    }
  }

  @override
  void setViewTransform(viewTransform) {
    //nothing to do
  }
}

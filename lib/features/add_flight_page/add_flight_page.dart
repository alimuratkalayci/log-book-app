import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../general_components/general_alert_dialog/general_alert_dialog.dart';
import '../../theme/theme.dart';

class AddFlightPage extends StatefulWidget {
  @override
  _AddFlightPageState createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  final _formKey = GlobalKey<FormState>();
  final _departureAirportController = TextEditingController();
  final _routeWayController = TextEditingController();
  final _arrivalAirportController = TextEditingController();
  final _airCraftController = TextEditingController();
  final _dateController = TextEditingController();
  final _totalTimeController = TextEditingController();
  final _nightTimeController = TextEditingController();
  final _picController = TextEditingController();
  final _dualRcvdController = TextEditingController();
  final _soloController = TextEditingController();
  final _xcController = TextEditingController();
  final _simInstController = TextEditingController();
  final _actualInstController = TextEditingController();
  final _simulatorController = TextEditingController();
  final _groundController = TextEditingController();
  final _instrumentApproachController = TextEditingController();
  final _dayToController = TextEditingController();
  final _dayLdgController = TextEditingController();
  final _nightToController = TextEditingController();
  final _nightLdgController = TextEditingController();
  final _remarksController = TextEditingController();
  final _hobbsInController = TextEditingController();
  final _hobbsOutController = TextEditingController();

  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String? selectedAircraftType;
  List<String> aircraftTypes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAircraftTypes();
  }

  Future<void> fetchAircraftTypes() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser == null) {
      setState(() {
        errorMessage = 'No user logged in';
        isLoading = false;
      });
      return;
    }

    final userEmail = currentUser.email;

    if (userEmail == null) {
      setState(() {
        errorMessage = 'User email is null';
        isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        if (data != null && data.containsKey('favorite_types')) {
          var favoriteTypesList = data['favorite_types'];
          if (favoriteTypesList is List) {
            setState(() {
              aircraftTypes = List<String>.from(favoriteTypesList);
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = "'favorite_types' is not a List";
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = "'favorite_types' field not found in the document";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'No document found for this user';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching favorite types: $e';
        isLoading = false;
      });
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _dateFormat.format(pickedDate);
      });
    });
  }

  Future<void> _saveFlightRecord() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final userEmail = currentUser.email;

      if (userEmail == null) {
        throw Exception('User email is null');
      }

      final double? totalTime = _totalTimeController.text.isNotEmpty
          ? double.tryParse(_totalTimeController.text)
          : 0.0;
      final double? nightTime = _nightTimeController.text.isNotEmpty
          ? double.tryParse(_nightTimeController.text)
          : 0.0;
      final double? pic = _picController.text.isNotEmpty
          ? double.tryParse(_picController.text)
          : 0.0;
      final double? dual_rcvd = _dualRcvdController.text.isNotEmpty
          ? double.tryParse(_dualRcvdController.text)
          : 0.0;
      final double? solo = _soloController.text.isNotEmpty
          ? double.tryParse(_soloController.text)
          : 0.0;
      final double? xc = _xcController.text.isNotEmpty
          ? double.tryParse(_xcController.text)
          : 0.0;
      final double? sim_inst = _simInstController.text.isNotEmpty
          ? double.tryParse(_simInstController.text)
          : 0.0;
      final double? actual_inst = _actualInstController.text.isNotEmpty
          ? double.tryParse(_actualInstController.text)
          : 0.0;
      final double? simulator = _simulatorController.text.isNotEmpty
          ? double.tryParse(_simulatorController.text)
          : 0.0;
      final double? ground = _groundController.text.isNotEmpty
          ? double.tryParse(_groundController.text)
          : 0.0;

      final int? intrumentApproach =
          _instrumentApproachController.text.isNotEmpty
              ? int.tryParse(_instrumentApproachController.text)
              : 0;
      final int? dayTakeoffs = _dayToController.text.isNotEmpty
          ? int.tryParse(_dayToController.text)
          : 0;
      final int? dayLandings = _dayLdgController.text.isNotEmpty
          ? int.tryParse(_dayLdgController.text)
          : 0;
      final int? nightTakeoffs = _nightToController.text.isNotEmpty
          ? int.tryParse(_nightToController.text)
          : 0;
      final int? nightLandings = _nightLdgController.text.isNotEmpty
          ? int.tryParse(_nightLdgController.text)
          : 0;

      final flightRecord = {
        'date': _dateController.text,
        'aircraft_type': selectedAircraftType,
        'aircraft_id': _airCraftController.text,
        'departure_airport': _departureAirportController.text,
        'route': _routeWayController.text,
        'arrival_airport': _arrivalAirportController.text,
        'hobbs_in': _hobbsInController.text.isEmpty
            ? int.tryParse('0')
            : int.tryParse(_hobbsInController.text),
        'hobbs_out': _hobbsOutController.text.isEmpty
            ? int.tryParse('0')
            : int.tryParse(_hobbsOutController.text),
        'total_time': totalTime,
        'night_time': nightTime,
        'pic': pic,
        'dual_rcvd': dual_rcvd,
        'solo': solo,
        'xc': xc,
        'sim_inst': sim_inst,
        'actual_inst': actual_inst,
        'simulator': simulator,
        'ground': ground,
        'instrument_approach': intrumentApproach,
        'day_to': dayTakeoffs,
        'day_ldg': dayLandings,
        'night_to': nightTakeoffs,
        'night_ldg': nightLandings,
        'remarks': _remarksController.text,
      };

      await firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('my_flights')
          .add(flightRecord);

      GeneralAlertDialog.show(context, "Flight record added");

      // Clear form fields if needed
      _formKey.currentState?.reset();
      _dateController.clear();
      _airCraftController.clear();
      _departureAirportController.clear();
      _routeWayController.clear();
      _arrivalAirportController.clear();
      _hobbsInController.clear();
      _hobbsOutController.clear();
      _totalTimeController.clear();
      _nightTimeController.clear();
      _picController.clear();
      _dualRcvdController.clear();
      _soloController.clear();
      _xcController.clear();
      _simInstController.clear();
      _actualInstController.clear();
      _simulatorController.clear();
      _groundController.clear();
      _instrumentApproachController.clear();
      _dayToController.clear();
      _dayLdgController.clear();
      _nightToController.clear();
      _nightLdgController.clear();
      _remarksController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding flight record: $e')),
      );
    }
  }

  void _updateTotalTime() {
    double? hobbsIn = double.tryParse(_hobbsInController.text);
    double? hobbsOut = double.tryParse(_hobbsOutController.text);
    if (hobbsIn != null && hobbsOut != null) {
      double totalTime = hobbsIn - hobbsOut;
      _totalTimeController.text = totalTime.toStringAsFixed(2);
    } else {
      _totalTimeController.text = '';
    }
  }

  InputDecoration customInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: AppTheme.TextColorWhite,
      ),
      hintText: 'Enter $labelText',
      hintStyle: TextStyle(
        color: AppTheme.TextColorWhite,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppTheme.TextColorWhite,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppTheme.TextColorWhite,
          width: 2.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppTheme.Green,
          width: 2.0,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.BackgroundColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 8, bottom: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.AccentColor,
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Flight',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.TextColorWhite)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _dateController,
                                    style: TextStyle(
                                        color: AppTheme.TextColorWhite),
                                    decoration: InputDecoration(
                                      focusColor: AppTheme.TextColorWhite,
                                      labelText: 'Date',
                                      labelStyle: TextStyle(
                                          color: AppTheme.TextColorWhite),
                                      hintText: _selectedDate == null
                                          ? 'No Date Chosen!'
                                          : _dateFormat
                                              .format(_selectedDate!)
                                              .toString(),
                                      hintStyle: TextStyle(
                                          color: AppTheme.TextColorWhite),
                                      border: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    onTap: _presentDatePicker,
                                    validator: (value) {
                                      if (_selectedDate == null) {
                                        return 'Please pick a date';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  color: AppTheme.TextColorWhite,
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: _presentDatePicker,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Favorite Aircrafts',
                                  style:
                                      TextStyle(color: AppTheme.TextColorWhite),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : errorMessage.isNotEmpty
                                          ? Text(errorMessage,
                                              style:
                                                  TextStyle(color: Colors.red))
                                          : DropdownButtonFormField<String>(
                                              dropdownColor:
                                                  AppTheme.AccentColor,
                                              iconEnabledColor:
                                                  AppTheme.TextColorWhite,
                                              iconSize: 24,
                                              elevation: 16,
                                              style: TextStyle(
                                                color: AppTheme.TextColorWhite,
                                                fontSize: 16,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 2.0, //
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide(
                                                    color: AppTheme.AccentColor,
                                                    width: 2.0,
                                                  ),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 12.0),
                                              ),
                                              icon: Icon(Icons.airplanemode_active),
                                              hint: Text(
                                                'Aircraft Types',
                                                style: TextStyle(
                                                    color: AppTheme
                                                        .TextColorWhite),
                                              ),
                                              value: selectedAircraftType,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedAircraftType =
                                                      newValue;
                                                });
                                              },
                                              items: aircraftTypes.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,
                                                      style: TextStyle(
                                                          color: AppTheme
                                                              .TextColorWhite)),
                                                );
                                              }).toList(),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Select an aircraft type';
                                                }
                                                return null;
                                              },
                                            ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _airCraftController,
                              decoration: customInputDecoration('Aircraft ID'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Aircraft ID';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _departureAirportController,
                              decoration:
                                  customInputDecoration('Departure Airport'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Departure Airport';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _routeWayController,
                              decoration: customInputDecoration('Route'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _arrivalAirportController,
                              decoration:
                                  customInputDecoration('Arrival Airport'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Arrival Airport';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _hobbsInController,
                              decoration: customInputDecoration('Hobbs In'),
                              style: TextStyle(
                                color: Colors.white, // Yazı rengi
                                fontSize: 16.0, // Yazı boyutu
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _hobbsOutController,
                              decoration: customInputDecoration('Hobbs Out'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              validator: (value) {
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                                _updateTotalTime();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.AccentColor,
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.TextColorWhite)),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _totalTimeController,
                              decoration: customInputDecoration('Total Time'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _nightTimeController,
                              decoration:
                                  customInputDecoration('Night Time').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _nightTimeController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _picController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration: customInputDecoration('PIC').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _picController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _dualRcvdController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration: customInputDecoration('Dual Received')
                                  .copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _dualRcvdController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _soloController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration:
                                  customInputDecoration('Solo').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _soloController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _xcController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration: customInputDecoration('XC').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _xcController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _simInstController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration:
                                  customInputDecoration('Sim Inst').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _simInstController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _actualInstController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration:
                                  customInputDecoration('Actual Inst').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _actualInstController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _simulatorController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration:
                                  customInputDecoration('Simulator').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _simulatorController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              controller: _groundController,
                              style: TextStyle(color: AppTheme.TextColorWhite),
                              decoration:
                                  customInputDecoration('Ground').copyWith(
                                suffixIcon: _totalTimeController.text.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0.0),
                                          child: TextButton(
                                            onPressed: () {
                                              double currentValue =
                                                  double.tryParse(
                                                          _totalTimeController
                                                              .text) ??
                                                      0.0;
                                              _groundController.text =
                                                  currentValue.toString();
                                            },
                                            child: Text(
                                              'Copy Time',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.TextColorWhite),
                                            ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _instrumentApproachController,
                              style: TextStyle(color: Colors.white),
                              decoration:
                                  customInputDecoration('Instrument Approach')
                                      .copyWith(
                                suffixIcon: IconButton(
                                  icon:
                                  Icon(Icons.add, color: Colors.green,size: 30,),
                                  onPressed: () {
                                    int currentValue = int.tryParse(
                                            _instrumentApproachController
                                                .text) ??
                                        0;
                                    _instrumentApproachController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.AccentColor,
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Landings',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.TextColorWhite)),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _dayToController,
                              style: TextStyle(color: Colors.white),
                              decoration: customInputDecoration('Day Takeoffs')
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon:
                                  Icon(Icons.add, color: Colors.green,size: 30,),
                                  onPressed: () {
                                    int currentValue =
                                        int.tryParse(_dayToController.text) ??
                                            0;
                                    _dayToController.text =
                                        (currentValue + 1).toString();
                                    _dayLdgController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _dayLdgController,
                              style: TextStyle(color: Colors.white),
                              decoration: customInputDecoration('Day Landings')
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon:
                                  Icon(Icons.add, color: Colors.green,size: 30,),
                                  onPressed: () {
                                    int currentValue =
                                        int.tryParse(_dayLdgController.text) ??
                                            0;
                                    _dayLdgController.text =
                                        (currentValue + 1).toString();
                                    _dayToController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _nightToController,
                              style: TextStyle(color: Colors.white),
                              decoration:
                                  customInputDecoration('Night Takeoffs')
                                      .copyWith(
                                suffixIcon: IconButton(
                                  icon:
                                  Icon(Icons.add, color: Colors.green,size: 30,),
                                  onPressed: () {
                                    int currentValue =
                                        int.tryParse(_nightToController.text) ??
                                            0;
                                    _nightToController.text =
                                        (currentValue + 1).toString();
                                    _nightLdgController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _nightLdgController,
                              style: TextStyle(color: Colors.white),
                              decoration:
                                  customInputDecoration('Night Landings')
                                      .copyWith(
                                suffixIcon: IconButton(
                                  icon:
                                      Icon(Icons.add, color: Colors.green,size: 30,),
                                  onPressed: () {
                                    int currentValue = int.tryParse(
                                            _nightLdgController.text) ??
                                        0;
                                    _nightLdgController.text =
                                        (currentValue + 1).toString();
                                    _nightToController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ),
                              validator: (value) {
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.AccentColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Remarks',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.TextColorWhite)),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _remarksController,
                                maxLines: null,
                                minLines: 1,
                                style: TextStyle(color: Colors.white),
                                decoration:
                                    customInputDecoration('Remarks').copyWith(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0), // İçerik dolgu alanı
                                ),
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveFlightRecord,
                              child: Text(
                                'Add Flight Record',
                                style: TextStyle(
                                    color: AppTheme.TextColorWhite,
                                    fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.AccentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

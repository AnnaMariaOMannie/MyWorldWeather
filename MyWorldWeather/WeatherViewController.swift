//  WeatherApp
//  ViewController.swift
//


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate
{
    
    //Constants
    //OpenWeatherMap Website
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "" //Sign in to  www.openweathermap.org and get your APPID
    

    //Instance variables:
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location Manager
        locationManager.delegate = self //Creating delegate to pick up data
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()


    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //getWeatherData method:
    func getWeatherData(url:String, parameters: [String: String]) {

    //Using Alamofire to make http (get)request and handle the response from the weather map servers. Alamofire makes request in a backround
     //Block of code provided by alamofire
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in //inside of clousure
            if response.result.isSuccess {
            //What we want to do with that data from server
             print("Success! Got the weather data") //Console

             let weatherJSON: JSON = JSON (response.result.value!)

            // print(weatherJSON) //console - copy and paste to www.jsoneditoronline.org
             self.updateWeatherData(json: weatherJSON)

             }

            else {
              print("Error \(String(describing: response.result.error))") //console print for check
             self.cityLabel.text = "Connection Issues" //Devices
                 }

  //Explanation: we are using Alamofire Library and we are using a method called request. That method use a few imputs: first is 'url' which comes from the input of getWeatherData to which we going to make our request(openWeatherApp).
    //Then method is a http method as a get request. Method dictates what we want to do with the data on a data server. Get method only retrieves data nothing else.
    //Final input are parameters which open weather map has specify in its documentation
    //So there are all the imputs which we need to give to weather map open servers in order to receive the weather condition data for that geographic location
    //Then we have a response from server using JSON. When response comes back we want to check if the response is succes or error.


        }

   }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //UpdateWeatherData method: pulling out relevant data from the output
     func updateWeatherData(json: JSON) {

      if

          let tempResult = json["main"]["temp"] .double {

        weatherDataModel.temperature = Int(tempResult - 273.15) // Converting from Kelvin to Celsius

        weatherDataModel.city = json["name"] .stringValue
        weatherDataModel.condition = json["weather"] [0] ["id"] .intValue //gradually going through json dict.

        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)

          updateUIWithWeatherData()

     } else {

           cityLabel.text = "Weather Unavailable"
            }

    }

    //MARK: - UI Updates
    /***************************************************************/
    
    
    //UpdateUIWithWeatherData method:
    
    func updateUIWithWeatherData()  {

        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
     weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)

     }


    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    // didUpdateLocations method. Sending information that new location data is found, then this method is activated:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations[locations.count - 1] // assuming that the last location will be the most acurrate

        if location.horizontalAccuracy > 0 {
         locationManager.stopUpdatingLocation()
         //thats enough to drain a user battery and we have  valid result
         locationManager.delegate = nil //to receive the data once

        print ("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")

        //Show it on devices:
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)

            let paramts: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]

        //Sending request (http) to the server of weather map giving coordinations
            getWeatherData(url:WEATHER_URL, parameters: paramts)

        }
    }

    
    // didFailWithError method.In case of error in retrieving of the location (no internet, etc):
    func locationManager(_ manager: CLLocationManager, didFailWithError         error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }


    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //The userEnteredANewCityName Delegate method:
    func userEnteredANewCityName(city: String) {
        //print(city)
        let paramts: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: paramts)
    }
    

    
    //The PrepareForSegue Method:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {

             let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self

        }
    }
}






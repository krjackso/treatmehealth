package controllers

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/asaskevich/govalidator"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/pressly/chi"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"
)

const (
	dateLayout = "02/01/2006"
)

type UserControllerImpl struct {
	UserModel models.UserModel
}

type UserController interface {
	Get(http.ResponseWriter, http.Request)
	Put(http.ResponseWriter, http.Request)
}

func (self *UserControllerImpl) Get(w http.ResponseWriter, r *http.Request) {
	userId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "id must be a number")
		return
	}

	ctx := r.Context()

	user, err := self.UserModel.GetById(ctx, userId)
	if err != nil {
		panic(err)
	}
	if user == nil {
		w.WriteHeader(404)
		return
	}

	body, err := json.Marshal(user)
	if err != nil {
		panic(err)
	}

	jsonstring := string(body[:])
	fmt.Fprintf(w, jsonstring)
}

type PutUserData struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Zip      string `json:"zip"`
	Dob      string `json:"dob"`
}

func validateUserData(data PutUserData) error {
	dob, dobErr := time.Parse(dateLayout, data.Dob)
	eighteenYearsAgo := time.Now().AddDate(-18, 0, 0)

	switch {
	case len([]rune(data.Username)) < 6:
		return errors.New("Username must be at least 6 characters")
	case !govalidator.IsEmail(data.Email):
		return errors.New("Invalid email address")
	case len([]rune(data.Password)) < 6:
		return errors.New("Password must be at least 6 characters")
	case len([]rune(data.Zip)) == 0:
		return errors.New("Zip code is required")
	case dobErr != nil:
		return errors.New("Invalid date of birth")
	case dob.After(eighteenYearsAgo):
		return errors.New("Must be at least 18 years old")
	default:
		return nil
	}
}

func (self *UserControllerImpl) Put(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(400)
		return
	}

	var data PutUserData
	err = json.Unmarshal(body, &data)
	if err != nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, err.Error())
		return
	}

	err = validateUserData(data)
	if err != nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, err.Error())
		return
	}

	dob, _ := time.Parse(dateLayout, data.Dob)
	ctx := r.Context()

	// See if there is already a user for this username/email
	user, err := self.UserModel.GetByUsername(ctx, data.Username)
	if err != nil {
		panic(err)
	}
	if user != nil {
		w.WriteHeader(409)
		fmt.Fprintf(w, "Username not available")
		return
	}

	user, err = self.UserModel.GetByEmail(ctx, data.Email)
	if err != nil {
		panic(err)
	}
	if user != nil {
		w.WriteHeader(409)
		fmt.Fprintf(w, "Email not available")
		return
	}

	credential := models.NewCredential(data.Password)

	user, err = self.UserModel.Create(ctx, data.Username, data.Email, credential, data.Zip, dob)
	if err != nil {
		panic(err)
	}

	// asdfsd
	refreshToken := models.NewRefreshToken()

	err = self.UserModel.AddRefreshToken(ctx, user.Id, refreshToken)
	if err != nil {
		println("Error adding refresh token: " + err.Error())
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	body, err = json.Marshal(&AuthResponse{
		RefreshToken: refreshToken.Token,
		AccessToken:  accessToken,
		ExpiresAt:    expiresAt,
	})
	if err != nil {
		panic(err)
	}
	w.WriteHeader(201)
	fmt.Fprint(w, string(body[:]))
}

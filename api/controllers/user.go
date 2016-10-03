package controllers

import (
	"encoding/json"
	"fmt"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/pressly/chi"
	"net/http"
	"strconv"
)

type UserControllerImpl struct {
	userModel models.UserModel
}

type UserController interface {
	Get(http.ResponseWriter, http.Request)
	List(http.ResponseWriter, http.Request)
}

func (self *UserControllerImpl) Get(w http.ResponseWriter, r *http.Request) {
	userId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "id must be a number")
		return
	}

	ctx := r.Context()

	user, err := self.userModel.GetById(ctx, userId)
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

func (self *UserControllerImpl) List(w http.ResponseWriter, r *http.Request) {
	username := chi.URLParam(r, "username")
	ctx := r.Context()

	user, err := self.userModel.GetByUsername(ctx, username)
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

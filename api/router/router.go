package router

import (
	"github.com/pressly/chi"
	"github.com/pressly/chi/middleware"
	"github.com/pressly/chi/render"
	"net/http"

	"github.com/krjackso/treatmehealth/api/controllers"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util/routes"
)

type BootstrapResponse struct {
	Login       string `json:"login"`
	Register    string `json:"register"`
	Logout      string `json:"logout"`
	CheckAuth   string `json:"check_auth"`
	RefreshAuth string `json:"refresh_auth"`
}

func NewRouter(userModel models.UserModel) *chi.Mux {
	router := chi.NewRouter()

	router.Use(middleware.RequestID)
	router.Use(middleware.RealIP)
	router.Use(middleware.Logger)
	router.Use(middleware.Recoverer)
	router.Use(middleware.CloseNotify)

	authCtl := &controllers.AuthControllerImpl{UserModel: userModel}
	userCtl := &controllers.UserControllerImpl{UserModel: userModel}

	router.Route(routes.Base, func(router chi.Router) {
		router.Get("/bootstrap", func(w http.ResponseWriter, r *http.Request) {
			render.JSON(w, r, &BootstrapResponse{
				Login:       routes.Login,
				Register:    routes.PutUser,
				Logout:      routes.Logout,
				CheckAuth:   routes.CheckAuth,
				RefreshAuth: routes.RefreshAuth,
			})
		})

		router.Head(routes.CheckAuth, authCtl.Index)
		router.Post(routes.Login, authCtl.Login)
		router.Post(routes.RefreshAuth, authCtl.Refresh)

		router.Put(routes.PutUser, userCtl.Put)

		// Authenticated routes
		router.Group(func(router chi.Router) {
			router.Use(Authenticated)

			router.Get(routes.GetUser, userCtl.Get)
		})
	})

	return router
}

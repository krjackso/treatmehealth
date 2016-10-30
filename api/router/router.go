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
	Login         string `json:"login"`
	Register      string `json:"register"`
	Logout        string `json:"logout"`
	CheckAuth     string `json:"checkAuth"`
	RefreshAuth   string `json:"refreshAuth"`
	ResetPassword string `json:"resetPassword"`
}

func NewRouter(userModel models.UserModel) *chi.Mux {
	router := chi.NewRouter()

	router.Use(middleware.RequestID)
	router.Use(middleware.RealIP)
	router.Use(middleware.Logger)
	router.Use(middleware.Recoverer)

	authCtl := &controllers.AuthControllerImpl{UserModel: userModel}
	userCtl := &controllers.UserControllerImpl{UserModel: userModel}

	router.Route(routes.Base, func(router chi.Router) {
		router.Get("/bootstrap", func(w http.ResponseWriter, r *http.Request) {
			render.JSON(w, r, &BootstrapResponse{
				Login:         routes.Absolute(routes.Login),
				Register:      routes.Absolute(routes.PutUser),
				Logout:        routes.Absolute(routes.Logout),
				CheckAuth:     routes.Absolute(routes.CheckAuth),
				RefreshAuth:   routes.Absolute(routes.RefreshAuth),
				ResetPassword: routes.Absolute(routes.RequestPasswordReset),
			})
		})

		router.Post(routes.Login, authCtl.Login)
		router.Post(routes.RefreshAuth, authCtl.Refresh)
		router.Post(routes.RequestPasswordReset, authCtl.RequestPasswordReset)

		router.Put(routes.PutUser, userCtl.Put)

		// Authenticated routes
		router.Group(func(router chi.Router) {
			router.Use(Authenticated)

			router.Head(routes.CheckAuth, authCtl.Index)
			router.Post(routes.Logout, authCtl.Logout)
			router.Get(routes.GetUser, userCtl.Get)
		})
	})

	return router
}

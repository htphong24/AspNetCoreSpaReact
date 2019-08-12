using AspnetCoreSPATemplate.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SpaServices.ReactDevelopmentServer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using AspnetCoreSPATemplate.Services.Common;
using SqlServerDataAccess;
using Microsoft.EntityFrameworkCore;
using AutoMapper;

namespace AspnetCoreSPATemplate
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHttpContextAccessor();

            if (Configuration["DataSource"] == "SqlServer")
            {
                // Auto Mapper
                services.AddAutoMapper(typeof(Startup));

                // Fetching Ccnnection string from appsettings.json
                string connectionString = Configuration.GetConnectionString("DbConstr");
                // Entity Framework
                services.AddDbContext<ContactsMgmtContext>(options => options.UseSqlServer(connectionString));
            }
            //services.AddTransient<IContactRepository, TestContactRepository>();
            //services.AddTransient<IContactRepository, CsvContactRepository>();
            //services.AddTransient<IContactRepository, CsvHelperContactRepository>();
            services.AddTransient<IContactRepository, SqlServerContactRepository>();
            services.AddTransient<IContactModificationRepository, SqlServerContactRepository>();

            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);

            // In production, the SPA files will be served from this directory
            services.AddSpaStaticFiles(configuration =>
            {
                configuration.RootPath = "app/dist";
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();
            app.UseSpaStaticFiles();

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller}/{action=Index}/{id?}");
            });

            app.UseSpa(spa =>
            {
                spa.Options.SourcePath = "app";

                if (env.IsDevelopment())
                {
                    //spa.UseProxyToSpaDevelopmentServer("http://localhost:8080");
                    spa.UseReactDevelopmentServer(npmScript: "start");
                }
            });
        }
    }
}

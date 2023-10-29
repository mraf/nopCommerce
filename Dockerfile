# Use the official Ubuntu as the base image
FROM ubuntu:latest

# create the build instance 
FROM mcr.microsoft.com/dotnet/sdk:7.0-bullseye-slim-arm32v7 AS build

WORKDIR /src                                                                    
COPY ./src ./

# restore solution
RUN dotnet restore NopCommerce.sln

WORKDIR /src/Presentation/Nop.Web   

# build project   
RUN dotnet build Nop.Web.csproj -c Release

# build plugins
WORKDIR /src/Plugins/Nop.Plugin.DiscountRules.CustomerRoles
RUN dotnet build Nop.Plugin.DiscountRules.CustomerRoles.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.ExchangeRate.EcbExchange
RUN dotnet build Nop.Plugin.ExchangeRate.EcbExchange.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.ExternalAuth.Facebook
RUN dotnet build Nop.Plugin.ExternalAuth.Facebook.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Misc.Brevo
RUN dotnet build Nop.Plugin.Misc.Brevo.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Misc.WebApi.Frontend
RUN dotnet build Nop.Plugin.Misc.WebApi.Frontend.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Misc.Zettle
RUN dotnet build Nop.Plugin.Misc.Zettle.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.MultiFactorAuth.GoogleAuthenticator
RUN dotnet build Nop.Plugin.MultiFactorAuth.GoogleAuthenticator.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.CheckMoneyOrder
RUN dotnet build Nop.Plugin.Payments.CheckMoneyOrder.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.CyberSource
RUN dotnet build Nop.Plugin.Payments.CyberSource.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.Manual
RUN dotnet build Nop.Plugin.Payments.Manual.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Payments.PayPalCommerce
RUN dotnet build Nop.Plugin.Payments.PayPalCommerce.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Pickup.PickupInStore
RUN dotnet build Nop.Plugin.Pickup.PickupInStore.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.FixedByWeightByTotal
RUN dotnet build Nop.Plugin.Shipping.FixedByWeightByTotal.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Shipping.UPS
RUN dotnet build Nop.Plugin.Shipping.UPS.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Tax.Avalara
RUN dotnet build Nop.Plugin.Tax.Avalara.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Tax.FixedOrByCountryStateZip
RUN dotnet build Nop.Plugin.Tax.FixedOrByCountryStateZip.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.FacebookPixel
RUN dotnet build Nop.Plugin.Widgets.FacebookPixel.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.GoogleAnalytics
RUN dotnet build Nop.Plugin.Widgets.GoogleAnalytics.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.NivoSlider
RUN dotnet build Nop.Plugin.Widgets.NivoSlider.csproj -c Release
WORKDIR /src/Plugins/Nop.Plugin.Widgets.What3words
RUN dotnet build Nop.Plugin.Widgets.What3words.csproj -c Release

# publish project
WORKDIR /src/Presentation/Nop.Web   
RUN dotnet publish Nop.Web.csproj -c Release -o /app/published

WORKDIR /app/published

RUN mkdir logs
RUN mkdir bin

RUN chmod 775 App_Data/
RUN chmod 775 App_Data/DataProtectionKeys
RUN chmod 775 bin
RUN chmod 775 logs
RUN chmod 775 Plugins
RUN chmod 775 wwwroot/bundles
RUN chmod 775 wwwroot/db_backups
RUN chmod 775 wwwroot/files/exportimport
RUN chmod 775 wwwroot/icons
RUN chmod 775 wwwroot/images
RUN chmod 775 wwwroot/images/thumbs
RUN chmod 775 wwwroot/images/uploaded

# create the runtime instance 
FROM mcr.microsoft.com/dotnet/runtime:7.0-bullseye-slim-arm32v7 AS runtime

# Update the package lists and install required packages
RUN apt-get update && apt-get install -y \
    libicu66 \
    libtiff5 \
    libgdiplus \
    libc6-dev \
    tzdata

# Clean up the package cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

WORKDIR /app

COPY --from=build /app/published .

EXPOSE 80
                            
ENTRYPOINT "/entrypoint.sh"

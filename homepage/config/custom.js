const onLoad = () => {
  const jellyfinSeries = [
    ...document.querySelectorAll("#jellyfin .service-block .text-xs"),
  ].find((el) => el.innerText.trim().toLowerCase() === "series");

  if (jellyfinSeries) jellyfinSeries.innerText = "tv shows";
};

window.addEventListener("load", onLoad);

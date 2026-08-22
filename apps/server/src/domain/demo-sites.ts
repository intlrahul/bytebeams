export type DemoSite = Readonly<{
  id: string;
  latitude: number;
  longitude: number;
  name: string;
}>;

export const demoSites = [
  site('sarjapur', 'Sarjapur Hub', 12.9016, 77.6877),
  site('electronic-city', 'Electronic City Depot', 12.8456, 77.6603),
  site('whitefield', 'Whitefield Service Yard', 12.9698, 77.7499),
  site('peenya', 'Peenya Logistics Hub', 13.0285, 77.5197),
  site('yelahanka', 'Yelahanka Charging Yard', 13.1007, 77.5963),
] as const satisfies readonly DemoSite[];

function site(id: string, name: string, latitude: number, longitude: number): DemoSite {
  return { id, name, latitude, longitude };
}
